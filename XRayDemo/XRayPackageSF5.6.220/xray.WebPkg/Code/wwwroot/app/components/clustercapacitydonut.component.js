System.register(["angular2/core", "./../models/clustercapacity"], function (exports_1, context_1) {
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
    var core_1, clustercapacity_1, ClusterCapacityDonut;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (clustercapacity_1_1) {
                clustercapacity_1 = clustercapacity_1_1;
            }
        ],
        execute: function () {
            ClusterCapacityDonut = (function () {
                function ClusterCapacityDonut() {
                }
                ClusterCapacityDonut.prototype.ngAfterViewInit = function () {
                    this.chart = new Chart(this.chartCanvasElement.nativeElement, {
                        type: 'doughnut',
                        data: {
                            labels: ['Load', 'Remaining capacity'],
                            datasets: [
                                {
                                    data: [0, 0],
                                    hoverBackgroundColor: ["#FFFFFF", "#CCCCCC"],
                                    borderWidth: 1,
                                    borderColor: "#000000"
                                }
                            ]
                        },
                        options: {
                            animation: {
                                duration: 0,
                                animateRotate: false
                            },
                            responsive: false,
                            cutoutPercentage: 90,
                            legend: {
                                display: false
                            }
                        }
                    });
                    if (this.data.capacity > 0) {
                        this.update();
                    }
                };
                ClusterCapacityDonut.prototype.ngOnChanges = function (changes) {
                    if (this.chart) {
                        this.update();
                    }
                };
                ClusterCapacityDonut.prototype.update = function () {
                    var dataset = this.chart.config.data.datasets[0];
                    dataset.data[0] = this.data.load;
                    dataset.data[1] = this.data.remainingCapacity;
                    dataset.backgroundColor = [this.getLoadColor(), "#666666"];
                    this.chart.update();
                };
                ClusterCapacityDonut.prototype.getLoadColor = function () {
                    if (this.data.isClusterCapacityViolation) {
                        return "#E81123";
                    }
                    if (this.data.load / this.data.capacity > 0.9) {
                        return "#FCD116";
                    }
                    return "#00ABEC";
                };
                return ClusterCapacityDonut;
            }());
            __decorate([
                core_1.Input(),
                __metadata("design:type", clustercapacity_1.ClusterCapacity)
            ], ClusterCapacityDonut.prototype, "data", void 0);
            __decorate([
                core_1.ViewChild("chartCanvas"),
                __metadata("design:type", core_1.ElementRef)
            ], ClusterCapacityDonut.prototype, "chartCanvasElement", void 0);
            ClusterCapacityDonut = __decorate([
                core_1.Component({
                    selector: 'cluster-capacity-donut',
                    templateUrl: 'app/components/clustercapacitydonut.component.html',
                    styleUrls: ['app/components/clustercapacitydonut.component.css']
                })
            ], ClusterCapacityDonut);
            exports_1("ClusterCapacityDonut", ClusterCapacityDonut);
        }
    };
});
//# sourceMappingURL=clustercapacitydonut.component.js.map