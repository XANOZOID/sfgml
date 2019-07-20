package sf.type;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
class SfClassField extends SfClassFieldImpl {
	public var index:Int = -1;
	public var callNeedsThis:Bool = false;
	public function new(parent:SfType, field:ClassField, inst:Bool) {
		super(parent, field, inst);
		if (inst) switch (field.kind) {
			case FMethod(_): callNeedsThis = true;
			default:
		}
	}
	public function getArgDoc(parState:Int):String {
		if (checkDocState(parState)) {
			var sfb = new SfBuffer();
			SfArgVars.doc(sfb, this, 4);
			return sfb.toString();
		} else return null;
	}
}
