System.register(["./viewmodel"], function (exports_1, context_1) {
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
    var viewmodel_1, NodeCapacityViewModel;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            }
        ],
        execute: function () {
            NodeCapacityViewModel = (function (_super) {
                __extends(NodeCapacityViewModel, _super);
                function NodeCapacityViewModel(isCapacityViolation, name, bufferedCapacity, capacity, load, remainingBufferedCapacity, remainingCapacity) {
                    var _this = _super.call(this, name) || this;
                    _this.isCapacityViolation = isCapacityViolation;
                    _this.name = name;
                    _this.bufferedCapacity = bufferedCapacity;
                    _this.capacity = capacity;
                    _this.load = load;
                    _this.remainingBufferedCapacity = remainingBufferedCapacity;
                    _this.remainingCapacity = remainingCapacity;
                    return _this;
                }
                NodeCapacityViewModel.prototype.copyFrom = function (other) {
                    this.name = other.name;
                    this.bufferedCapacity = other.bufferedCapacity;
                    this.capacity = other.capacity;
                    this.isCapacityViolation = other.isCapacityViolation;
                    this.load = other.load;
                    this.remainingBufferedCapacity = other.remainingBufferedCapacity;
                    this.remainingCapacity = other.remainingCapacity;
                };
                return NodeCapacityViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("NodeCapacityViewModel", NodeCapacityViewModel);
        }
    };
});
//# sourceMappingURL=nodecapacityviewmodel.js.map