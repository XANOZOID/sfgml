package haxe;
import gml.internal.StdTypeImpl;

/**
 * ...
 * @author YellowAfterlife
 */
#if (macro || display || eval)
extern class Exception {
	/**
		Exception message.
	**/
	public var message(get,never):String;
	private function get_message():String;

	/**
		The call stack at the moment of the exception creation.
	**/
	public var stack(get,never):CallStack;
	private function get_stack():CallStack;

	/**
		Contains an exception, which was passed to `previous` constructor argument.
	**/
	public var previous(get,never):Null<Exception>;
	private function get_previous():Null<Exception>;

	/**
		Native exception, which caused this exception.
	**/
	public var native(get,never):Any;
	final private function get_native():Any;

	/**
		Used internally for wildcard catches like `catch(e:Exception)`.
	**/
	static private function caught(value:Any):Exception;

	/**
		Used internally for wrapping non-throwable values for `throw` expressions.
	**/
	static private function thrown(value:Any):Any;

	/**
		Create a new Exception instance.

		The `previous` argument could be used for exception chaining.

		The `native` argument is for internal usage only.
		There is no need to provide `native` argument manually and no need to keep it
		upon extending `haxe.Exception` unless you know what you're doing.
	**/
	public function new(message:String, ?previous:Exception, ?native:Any):Void;

	/**
		Extract an originally thrown value.

		Used internally for catching non-native exceptions.
		Do _not_ override unless you know what you are doing.
	**/
	private function unwrap():Any;

	/**
		Returns exception message.
	**/
	public function toString():String;

	/**
		Detailed exception description.

		Includes message, stack and the chain of previous exceptions (if set).
	**/
	public function details():String;

	/**
		If this field is defined in a target implementation, then a call to this
		field will be generated automatically in every constructor of derived classes
		to make exception stacks point to derived constructor invocations instead of
		`super` calls.
	**/
	// @:noCompletion @:ifFeature("haxe.Exception.stack") private function __shiftStack():Void;
}
#else
class Exception {
	public var message:String;
	
	// Haxe:
	public var stack:CallStack;
	public var previous:Null<Exception>;
	public var native:Any;
	
	// GML:
	public var longMessage:String;
	public var script:String;
	public var stacktrace:Array<String>;
	
	public function new(message:String, ?previous:Exception, ?native:Any) {
		this.native = native != null ? native : this;
	}
	public function details():String {
		return "???";
	}
	
	#if sfgml.modern
	public static function thrown(value:Any):Any {
		if (StdTypeImpl.is(value, Exception)) {
			return (value:Exception).native;
		} else {
			var e = new ValueException(value);
			untyped __feature__("haxe.Exception.get_stack", e.__shiftStack());
			return e;
		}
	}
	#else
	public static inline function thrown(value:Any):Any {
		return Std.string(value);
	}
	#end
	
	function unwrap():Any {
		return native;
	}
	
	public function toString():String {
		return message;
	}
}
#end