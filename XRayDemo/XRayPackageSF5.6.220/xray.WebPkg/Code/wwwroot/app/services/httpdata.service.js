System.register(["./data.service", "angular2/core", "angular2/http", "rxjs/Observable"], function (exports_1, context_1) {
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
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __metadata = (this && this.__metadata) || function (k, v) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
    };
    var __moduleName = context_1 && context_1.id;
    var data_service_1, core_1, http_1, Observable_1, HttpDataService;
    return {
        setters: [
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (http_1_1) {
                http_1 = http_1_1;
            },
            function (Observable_1_1) {
                Observable_1 = Observable_1_1;
            }
        ],
        execute: function () {
            HttpDataService = (function (_super) {
                __extends(HttpDataService, _super);
                function HttpDataService(http) {
                    var _this = _super.call(this) || this;
                    _this.http = http;
                    _this.refreshInterval = 10;
                    _this.apiUrl = "api/";
                    return _this;
                }
                HttpDataService.prototype.getApplicationModels = function (nodeName, appTypeFilter) {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var filterArray = appTypeFilter();
                        var filterString = filterArray
                            ? filterArray.join(",")
                            : "";
                        return _this.http.get(_this.apiUrl + 'application/' + nodeName + '/' + filterString).catch(_this.handleError);
                    })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getClusterInfo = function () {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return _this.http.get(_this.apiUrl + 'cluster/info'); })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getClusterFilters = function () {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return _this.http.get(_this.apiUrl + 'cluster/filters'); })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getClusterCapacity = function () {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () { return _this.http.get(_this.apiUrl + 'cluster/capacity').catch(_this.handleError); })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getClusterCapacityHistory = function (capacityName, startDate) {
                    var _this = this;
                    var start = startDate ?
                        startDate :
                        new Date(Date.now() - 3600000);
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var result = _this.http.get(_this.apiUrl + 'cluster/history/' + capacityName + '/' + start.toISOString()).catch(_this.handleError);
                        start = new Date(Date.now());
                        return result;
                    })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getNodes = function (nodeTypeFilter) {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        var nodeTypeArray = nodeTypeFilter();
                        var nodeTypeString = nodeTypeArray
                            ? nodeTypeArray.join(",")
                            : "";
                        return _this.http.get(_this.apiUrl + 'node/info/' + nodeTypeString).catch(_this.handleError);
                    })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.getNodeCapacity = function (nodeName) {
                    var _this = this;
                    return Observable_1.Observable
                        .interval(this.refreshInterval * 1000)
                        .startWith(-1)
                        .flatMap(function () {
                        return _this.http.get(_this.apiUrl + 'node/capacity/' + nodeName).catch(_this.handleError);
                    })
                        .map(this.extractData)
                        .catch(this.handleError);
                };
                HttpDataService.prototype.extractData = function (res) {
                    if (res.status < 200 || res.status >= 400) {
                        return null;
                    }
                    var body = res.json();
                    return body;
                };
                HttpDataService.prototype.handleError = function (error) {
                    // In a real world app, we might send the error to remote logging infrastructure
                    var errMsg = error.message || 'Server error';
                    console.log(errMsg); // log to console instead
                    return Observable_1.Observable.empty();
                };
                return HttpDataService;
            }(data_service_1.DataService));
            HttpDataService = __decorate([
                core_1.Injectable(),
                __metadata("design:paramtypes", [http_1.Http])
            ], HttpDataService);
            exports_1("HttpDataService", HttpDataService);
        }
    };
});
//# sourceMappingURL=httpdata.service.js.map