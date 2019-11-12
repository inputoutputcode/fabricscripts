System.register([], function (exports_1, context_1) {
    "use strict";
    var __moduleName = context_1 && context_1.id;
    var ViewModel;
    return {
        setters: [],
        execute: function () {
            ViewModel = (function () {
                function ViewModel(comparisonId) {
                    this.comparisonId = comparisonId;
                }
                ViewModel.prototype.equals = function (other) {
                    return !other || (this.comparisonId == other.comparisonId);
                };
                return ViewModel;
            }());
            exports_1("ViewModel", ViewModel);
        }
    };
});
//# sourceMappingURL=viewmodel.js.map