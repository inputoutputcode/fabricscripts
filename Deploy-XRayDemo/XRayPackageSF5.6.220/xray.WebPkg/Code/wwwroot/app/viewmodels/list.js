System.register([], function (exports_1, context_1) {
    "use strict";
    var __moduleName = context_1 && context_1.id;
    var List;
    return {
        setters: [],
        execute: function () {
            List = (function () {
                function List() {
                }
                List.updateList = function (oldList, newList) {
                    if (!newList) {
                        console.log("nothing new");
                        return;
                    }
                    var _loop_1 = function (i) {
                        var oldItem = oldList[i];
                        if (!newList.find(function (x) { return x.equals(oldItem); })) {
                            oldList.splice(i, 1);
                        }
                    };
                    // remove items that aren't in the new list
                    for (var i = 0; i < oldList.length; ++i) {
                        _loop_1(i);
                    }
                    var _loop_2 = function (i) {
                        var newItem = newList[i];
                        var oldItem = oldList.find(function (x) { return x.equals(newItem); });
                        if (!oldItem) {
                            oldList.push(newItem);
                        }
                        else {
                            oldItem.copyFrom(newItem);
                        }
                    };
                    // add or update items from then new list
                    for (var i = 0; i < newList.length; ++i) {
                        _loop_2(i);
                    }
                };
                return List;
            }());
            exports_1("List", List);
        }
    };
});
//# sourceMappingURL=list.js.map