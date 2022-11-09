@:structInit class Jevko {
    static public function main():Void {
        var jevko = Jevko.parse("a [b] c");
        trace(jevko);
    }

    static var escaper = "`";
    static var opener = "[";
    static var closer = "]";

    static public function parse(str: String): Jevko {
        var parents = new List<Jevko>();
        var parent: Jevko = {subjevkos: new List<Subjevko>()};
        var prefix = '';
        var h = 0;
        var isEscaped = false;
        var line = 1;
        var column = 1;

        var i = 0;
        while (i < str.length) {
            var c = str.charAt(i);

            if (isEscaped) {
                if (c == escaper || c == opener || c == closer) isEscaped = false;
                else throw 'Invalid digraph (${escaper}${c}) at ${line}:${column}!';
            } else if (c == escaper) {
                prefix += str.substring(h, i);
                h = i + 1;
                isEscaped = true;
            } else if (c == opener) {
                var jevko: Jevko = {subjevkos: new List<Subjevko>()};
                parent.subjevkos.push({
                    prefix: prefix + str.substring(h, i), 
                    jevko: jevko
                });
                prefix = '';
                h = i + 1;
                parents.push(parent);
                parent = jevko;
            } else if (c == closer) {
                parent.suffix = prefix + str.substring(h, i);
                prefix = '';
                h = i + 1;
                if (parents.length < 1) throw ('Unexpected closer (${closer}) at ${line}:${column}!');
                parent = parents.pop();
            }

            if (c == '\n') {
                ++line;
                column = 1;
            } else {
                ++column;
            }

            ++i;
        }
        if (isEscaped) throw ('Unexpected end after escaper (${escaper})!');

        if (parents.length > 0) throw ('Unexpected end: missing ${parents.length} closer(s) (${closer})!');

        parent.suffix = prefix + str.substring(h);
        //parent.opener = opener
        //parent.closer = closer
        //parent.escaper = escaper
        return parent;
    }
    public static function escape(str: String) {
        var ret = '';
        var i = 0;
        while (i < str.length) {
            var c = str.charAt(i);
            if (c == opener || c == closer || c == escaper) ret += escaper;
            ret += c;
            ++i;
        }
        return ret;
    }

    public function toString() {
        var i = 0;
        var ret = "";

        for (sub in this.subjevkos) {
            ret += '${Jevko.escape(sub.prefix)}${opener}${sub.jevko}${closer}';

            ++i;
        }
        return ret + Jevko.escape(this.suffix);
    }

    public var subjevkos: List<Subjevko>;
    public var suffix: String;

    public inline function new(
        subjevkos: List<Subjevko>, 
        suffix: String = ""
    ) {
        this.subjevkos = subjevkos;
        this.suffix = suffix;
    }
}

@:structInit class Subjevko {
    public var prefix: String;
    public var jevko: Jevko;

    public function new(prefix: String, jevko: Jevko) {
        this.prefix = prefix;
        this.jevko = jevko;
    }
}