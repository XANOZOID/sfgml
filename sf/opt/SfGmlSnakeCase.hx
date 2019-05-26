package sf.opt;

import haxe.macro.Expr.Binop;
import sf.opt.SfOptImpl;
import sf.type.SfExprDef.*;
import sf.type.*;
using sf.type.SfExprTools;
import sf.SfCore.*;
import haxe.macro.Expr.Binop.*;

/**
 * ...
 * @author YellowAfterlife
 */
class SfGmlSnakeCase extends SfOptImpl {
	/**
	 * Converts a string from camelCase to snake_case.
	 */
	public static function toSnakeCase(s:String):String {
		var n = s.length;
		// early exit if the string is already in snake_case:
		var i = -1;
		while (++i < n) {
			var c = StringTools.fastCodeAt(s, i); // or s.charCodeAt(i)
			if (c >= "A".code && c <= "Z".code) break;
		}
		if (i >= n) return s;
		// otherwise form it via a string buffer:
		var r = new StringBuf();
		var p = 0;
		for (i in 0 ... n) {
			var c = StringTools.fastCodeAt(s, i);
			if (c >= "A".code && c <= "Z".code) {
				if (p >= "a".code && p <= "z".code
				 || p >= "0".code && p <= "9".code) { // "eC" -> "e_c"
					r.addChar("_".code);
				}
				r.addChar(c + ("a".code - "A".code));
			} else r.addChar(c);
			p = c;
		}
		return r.toString();
	}
	public static function checkType(q:SfType):Bool {
		return q.meta.has(":snakeCase")
			// with -D sfgml_snake_case, we don't touch extern and/or std classes
			|| sfConfig.snakeCase && !(q.isHidden || q.meta.has(":std"));
	}
	public static function applyToType(q:SfType):Void {
		if (!q.meta.has(":native") && !q.meta.has(":expose")) {
			var qp = q.pack;
			for (i in 0 ... qp.length) qp[i] = toSnakeCase(qp[i]);
			q.name = toSnakeCase(q.name);
		}
	}
	public static function procClass(c:SfClass) {
		if (checkType(c)
			// weird, but - we need it for (extern) enum abstract implementation classes
			|| sfConfig.snakeCase && c.meta.has(":enum")
		) {
			applyToType(c);
			for (f in c.fieldList) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					c.renameField(f, toSnakeCase(f.name));
				}
			}
		}
	}
	public static function procEnum(e:SfEnum) {
		if (checkType(e)) {
			applyToType(e);
			for (f in e.ctrList) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					f.name = toSnakeCase(f.name);
				}
			}
		}
	}
	public static function procAnon(a:SfAnon):Void {
		if (a.meta.has(":snakeCase")) {
			applyToType(a);
			for (f in a.fields) {
				if (!f.meta.has(":native") && !f.meta.has(":expose")) {
					f.name = toSnakeCase(f.name);
				}
			}
		}
	}
	
	override public function apply():Void {
		for (c in sfGenerator.classList) procClass(c);
		for (e in sfGenerator.enumList) procEnum(e);
		for (a in sfGenerator.anonList) procAnon(a);
	}
}