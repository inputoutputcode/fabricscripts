System.register(["angular2/core", "angular2/router", "./cluster.component", "./service-detail.component", "./../services/data.service", "./../services/httpdata.service", "./dashboard.component", "angular2/http"], function (exports_1, context_1) {
    "use strict";
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __moduleName = context_1 && context_1.id;
    var core_1, router_1, cluster_component_1, service_detail_component_1, data_service_1, httpdata_service_1, dashboard_component_1, http_1, AppComponent;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (router_1_1) {
                router_1 = router_1_1;
            },
            function (cluster_component_1_1) {
                cluster_component_1 = cluster_component_1_1;
            },
            function (service_detail_component_1_1) {
                service_detail_component_1 = service_detail_component_1_1;
            },
            function (data_service_1_1) {
                data_service_1 = data_service_1_1;
            },
            function (httpdata_service_1_1) {
                httpdata_service_1 = httpdata_service_1_1;
            },
            function (dashboard_component_1_1) {
                dashboard_component_1 = dashboard_component_1_1;
            },
            function (http_1_1) {
                http_1 = http_1_1;
            }
        ],
        execute: function () {
            AppComponent = (function () {
                function AppComponent() {
                }
                AppComponent.prototype.ngOnInit = function () {
                    this.clusterAddress = window.location.hostname;
                };
                return AppComponent;
            }());
            AppComponent = __decorate([
                router_1.RouteConfig([
                    {
                        path: '/cluster',
                        name: 'Cluster',
                        component: cluster_component_1.ClusterComponent
                    },
                    {
                        path: '/dashboard',
                        name: 'Dashboard',
                        component: dashboard_component_1.DashboardComponent,
                        useAsDefault: true
                    },
                    {
                        path: '/service/:id',
                        name: 'ServiceDetail',
                        component: service_detail_component_1.ServiceDetailComponent
                    }
                ]),
                core_1.Component({
                    selector: 'xray',
                    templateUrl: 'app/components/app.component.html',
                    styleUrls: ['app/components/app.component.css'],
                    directives: [router_1.ROUTER_DIRECTIVES],
                    providers: [http_1.HTTP_PROVIDERS, router_1.ROUTER_PROVIDERS, core_1.provide(data_service_1.DataService, { useClass: httpdata_service_1.HttpDataService })]
                })
            ], AppComponent);
            exports_1("AppComponent", AppComponent);
        }
    };
});
//# sourceMappingURL=app.component.js.map