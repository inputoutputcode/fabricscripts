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
    var viewmodel_1, DeployedReplicaViewModel;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            }
        ],
        execute: function () {
            DeployedReplicaViewModel = (function (_super) {
                __extends(DeployedReplicaViewModel, _super);
                function DeployedReplicaViewModel(highlighted, selectedMetric, selectedClass, roleClass, replica) {
                    var _this = _super.call(this, replica.partitionId + replica.id) || this;
                    _this.highlighted = highlighted;
                    _this.selectedMetric = selectedMetric;
                    _this.selectedClass = selectedClass;
                    _this.roleClass = roleClass;
                    _this.replica = replica;
                    return _this;
                }
                DeployedReplicaViewModel.prototype.copyFrom = function (other) {
                    this.replica = other.replica;
                    this.roleClass = other.roleClass;
                    this.selectedMetric = other.selectedMetric;
                    this.selectedClass = other.selectedClass;
                };
                return DeployedReplicaViewModel;
            }(viewmodel_1.ViewModel));
            exports_1("DeployedReplicaViewModel", DeployedReplicaViewModel);
        }
    };
});
//# sourceMappingURL=deployedreplicaviewmodel.js.map