package haxe;
@:coreApi class ValueException extends Exception {
	/**
		Thrown value.
	**/
	public var value(default,null):Any;

	public function new(value:Any, ?previous:Exception, ?native:Any):Void {
		super(Std.string(value), previous, native);
		this.value = value;
	}

	/**
		Extract an originally thrown value.

		This method must return the same value on subsequent calls.
		Used internally for catching non-native exceptions.
		Do _not_ override unless you know what you are doing.
	**/
	override function unwrap():Any {
		return value;
	}
}