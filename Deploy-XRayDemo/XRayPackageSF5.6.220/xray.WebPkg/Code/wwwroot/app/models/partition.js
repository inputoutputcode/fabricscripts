System.register([], function (exports_1, context_1) {
    "use strict";
    var __extends = (this && this.__extends) || (function () {
        var extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return function (d, b) {
            extendStatics(d, b);
            function __() { this.constructor = d; }
            d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
        };
    })();
    var __moduleName = context_1 && context_1.id;
    var Partition, StatelessPartition, StatefulPartition, Int64StatefulPartition;
    return {
        setters: [],
        execute: function () {
            Partition = (function () {
                function Partition() {
                }
                return Partition;
            }());
            exports_1("Partition", Partition);
            StatelessPartition = (function (_super) {
                __extends(StatelessPartition, _super);
                function StatelessPartition() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StatelessPartition;
            }(Partition));
            exports_1("StatelessPartition", StatelessPartition);
            StatefulPartition = (function (_super) {
                __extends(StatefulPartition, _super);
                function StatefulPartition() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return StatefulPartition;
            }(Partition));
            exports_1("StatefulPartition", StatefulPartition);
            Int64StatefulPartition = (function (_super) {
                __extends(Int64StatefulPartition, _super);
                function Int64StatefulPartition() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return Int64StatefulPartition;
            }(StatefulPartition));
            exports_1("Int64StatefulPartition", Int64StatefulPartition);
        }
    };
});
//# sourceMappingURL=partition.js.map