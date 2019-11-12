System.register(["angular2/core", "./../models/service", "./../services/data.service", "angular2/router"], function (exports_1, context_1) {
    "use strict";
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
    var core_1, service_1, data_service_1, router_1, ServiceDetailComponent;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (service_1_1) {
                service_1 = service_1_1;
            },
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (router_1_1) {
                router_1 = router_1_1;
            }
        ],
        execute: function () {
            ServiceDetailComponent = (function () {
                function ServiceDetailComponent(dataService, routeParams) {
                    this.dataService = dataService;
                    this.routeParams = routeParams;
                }
                ServiceDetailComponent.prototype.ngOnInit = function () {
                    var id = +this.routeParams.get('id');
                    //this.dataService.getService('name')
                    //    .then(result => this.service = result);
                };
                ServiceDetailComponent.prototype.goBack = function () {
                    window.history.back();
                };
                return ServiceDetailComponent;
            }());
            __decorate([
                core_1.Input(),
                __metadata("design:type", service_1.Service)
            ], ServiceDetailComponent.prototype, "service", void 0);
            ServiceDetailComponent = __decorate([
                core_1.Component({
                    selector: 'service-detail',
                    templateUrl: 'app/components/service-detail.component.html'
                }),
                __metadata("design:paramtypes", [data_service_1.DataService,
                    router_1.RouteParams])
            ], ServiceDetailComponent);
            exports_1("ServiceDetailComponent", ServiceDetailComponent);
        }
    };
});
//# sourceMappingURL=service-detail.component.js.map