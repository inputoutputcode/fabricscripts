System.register([], function (exports_1, context_1) {
    "use strict";
    var __moduleName = context_1 && context_1.id;
    var Color;
    return {
        setters: [],
        execute: function () {
            Color = (function () {
                function Color(r, g, b) {
                    this.r = r;
                    this.g = g;
                    this.b = b;
                }
                Color.prototype.toRBGAString = function (a) {
                    return 'rgba(' + this.r + ',' + this.g + ',' + this.b + ',' + a + ')';
                };
                Color.fromHSV = function (h, s, v) {
                    h /= 360;
                    s /= 100;
                    v /= 100;
                    var r, g, b = 0;
                    var i = Math.floor(h * 6);
                    var f = h * 6 - i;
                    var p = v * (1 - s);
                    var q = v * (1 - f * s);
                    var t = v * (1 - (1 - f) * s);
                    switch (i % 6) {
                        case 0:
                            r = v, g = t, b = p;
                            break;
                        case 1:
                            r = q, g = v, b = p;
                            break;
                        case 2:
                            r = p, g = v, b = t;
                            break;
                        case 3:
                            r = p, g = q, b = v;
                            break;
                        case 4:
                            r = t, g = p, b = v;
                            break;
                        case 5:
                            r = v, g = p, b = q;
                            break;
                    }
                    return new Color(Math.round(r * 255), Math.round(g * 255), Math.round(b * 255));
                };
                return Color;
            }());
            exports_1("Color", Color);
        }
    };
});
//# sourceMappingURL=color.js.map