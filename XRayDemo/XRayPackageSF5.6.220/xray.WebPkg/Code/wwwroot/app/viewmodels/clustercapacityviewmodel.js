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
    var viewmodel_1, ClusterCapacityViewModel;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            }
        ],
        execute: function () {
            ClusterCapacityViewModel = (function (_super) {
                __extends(ClusterCapacityViewModel, _super);
                function ClusterCapacityViewModel(bufferedCapacity, capacity, load, remainingBufferedCapacity, remainingCapacity, isClusterCapacityViolation, name, bufferPercentage, balancedBefore, balancedAfter, deviationBefore, deviationAfter, balancingThreshold, maxLoadedNode, minLoadedNode, selected) {
                    var _this = _super.call(this, name) || this;
                    _this.bufferedCapacity = bufferedCapacity;
                    _this.capacity = capacity;
                    _this.load = load;
                    _this.remainingBufferedCapacity = remainingBufferedCapacity;
                    _this.remainingCapacity = remainingCapacity;
                    _this.isClusterCapacityViolation = isClusterCapacityViolation;
                    _this.name = name;
                    _this.bufferPercentage = bufferPercentage;
                    _this.balancedBefore = balancedBefore;
                    _this.balancedAfter = balancedAfter;
                    _this.deviationBefore = deviationBefore;
                    _this.deviationAfter = deviationAfter;
                    _this.balancingThreshold = balancingThreshold;
                    _this.maxLoadedNode = maxLoadedNode;
                    _this.minLoadedNode = minLoadedNode;
                    _this.selected = selected;
                    return _this;
                }
                ClusterCapacityViewModel.prototype.copyFrom = function (other) {
                    this.bufferedCapacity = other.bufferedCapacity;
                    this.bufferPercentage = other.bufferPercentage;
                    this.capacity = other.capacity;
                    this.isClusterCapacityViolation = other.isClusterCapacityViolation;
                    this.load = other.load;
                    this.remainingBufferedCapacity = other.remainingBufferedCapacity;
                    this.remainingCapacity = other.remainingCapacity;
                    this.balancedAfter = other.balancedAfter;
                    this.balancedBefore = other.balancedBefore;
                    this.deviationAfter = other.deviationAfter;
                    this.deviationBefore = other.deviationBefore;
                    this.balancingThreshold = other.balancingThreshold;
                    this.maxLoadedNode = other.maxLoadedNode;
                    this.minLoadedNode = other.minLoadedNode;
                };
                return ClusterCapacityViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("ClusterCapacityViewModel", ClusterCapacityViewModel);
        }
    };
});
//# sourceMappingURL=clustercapacityviewmodel.js.map