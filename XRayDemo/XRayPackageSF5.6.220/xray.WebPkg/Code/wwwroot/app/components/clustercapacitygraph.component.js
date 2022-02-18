System.register(["angular2/core", "rxjs/Rx", "./../color"], function (exports_1, context_1) {
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
    var core_1, Rx_1, color_1, DataStream, ClusterCapacityGraph;
    return {
        setters: [
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (Rx_1_1) {
                Rx_1 = Rx_1_1;
            },
            function (color_1_1) {
                color_1 = color_1_1;
            }
        ],
        execute: function () {
            DataStream = (function () {
                function DataStream(name, stream) {
                    this.name = name;
                    this.stream = stream;
                }
                return DataStream;
            }());
            exports_1("DataStream", DataStream);
            ClusterCapacityGraph = (function () {
                function ClusterCapacityGraph() {
                }
                ClusterCapacityGraph.prototype.ngAfterViewInit = function () {
                    var _this = this;
                    this.chart = new Chart(this.chartCanvasElement.nativeElement, {
                        type: 'line',
                        data: {
                            labels: [],
                            datasets: []
                        },
                        options: {
                            scales: {
                                xAxes: [{
                                        gridLines: {
                                            color: "#333333",
                                        }
                                    }],
                                yAxes: [{
                                        gridLines: {
                                            color: "#333333",
                                        }
                                    }]
                            }
                        }
                    });
                    this.capacityHistory.subscribe(function (dataStream) {
                        if (!dataStream) {
                            return;
                        }
                        dataStream.stream.subscribe(function (next) {
                            _this.addData(dataStream.name, next);
                        }, function (error) {
                            // this.removeData(dataStream.name);
                        }, function () {
                            _this.removeData(dataStream.name);
                        });
                    }, function (error) {
                        console.log("error: " + error);
                    }, function () {
                        console.log("complete");
                    });
                };
                ClusterCapacityGraph.prototype.removeData = function (label) {
                    var ix = this.chart.config.data.datasets.findIndex(function (x) { return x.label == label; });
                    if (ix >= 0) {
                        this.chart.config.data.datasets.splice(ix, 1);
                    }
                    this.chart.update();
                };
                ClusterCapacityGraph.prototype.addData = function (name, data) {
                    var labels = this.chart.config.data.labels;
                    var dataset = this.chart.config.data.datasets.find(function (x) { return x.label == name; });
                    if (!dataset) {
                        var ix = this.chart.config.data.datasets.length;
                        var h = 196;
                        var s = (35 - ((ix % 6) * 5));
                        var v = (70 - ((ix % 6) * 10));
                        var fillColor = color_1.Color.fromHSV(h, s, v);
                        var highlightColor = color_1.Color.fromHSV(h, s, 100);
                        dataset = {
                            label: name,
                            lineTension: 0.2,
                            borderColor: fillColor.toRBGAString(1),
                            pointBorderColor: fillColor.toRBGAString(1),
                            backgroundColor: fillColor.toRBGAString(0.2),
                            pointBackgroundColor: fillColor.toRBGAString(0.2),
                            pointRadius: 1,
                            pointHoverRadius: 2,
                            pointHitRadius: 15,
                            pointHoverBorderColor: "rgba(255, 255, 255, 1)",
                            pointHoverBackgroundColor: fillColor.toRBGAString(1),
                            borderWidth: 1,
                            data: []
                        };
                        this.chart.config.data.datasets.push(dataset);
                        for (var _i = 0, labels_1 = labels; _i < labels_1.length; _i++) {
                            var label = labels_1[_i];
                            dataset.data.push(0);
                        }
                    }
                    for (var _a = 0, data_1 = data; _a < data_1.length; _a++) {
                        var item = data_1[_a];
                        var timestamp = this.formatDateLabel(item.timestamp);
                        var ix = labels.indexOf(timestamp);
                        if (ix < 0) {
                            labels.push(timestamp);
                        }
                    }
                    labels.sort();
                    for (var _b = 0, data_2 = data; _b < data_2.length; _b++) {
                        var item = data_2[_b];
                        var timestamp = this.formatDateLabel(item.timestamp);
                        var ix = labels.indexOf(timestamp);
                        dataset.data[ix] = item.data;
                    }
                    this.chart.update();
                };
                ClusterCapacityGraph.prototype.formatDateLabel = function (date) {
                    return dateFormat(date, 'mm/dd/yy HH:MM:ss');
                };
                return ClusterCapacityGraph;
            }());
            __decorate([
                core_1.ViewChild("chartCanvas"),
                __metadata("design:type", core_1.ElementRef)
            ], ClusterCapacityGraph.prototype, "chartCanvasElement", void 0);
            __decorate([
                core_1.Input(),
                __metadata("design:type", Rx_1.Observable)
            ], ClusterCapacityGraph.prototype, "capacityHistory", void 0);
            ClusterCapacityGraph = __decorate([
                core_1.Component({
                    selector: 'cluster-capacity-graph',
                    templateUrl: 'app/components/clustercapacitygraph.component.html',
                    styleUrls: ['app/components/clustercapacitygraph.component.css']
                }),
                __metadata("design:paramtypes", [])
            ], ClusterCapacityGraph);
            exports_1("ClusterCapacityGraph", ClusterCapacityGraph);
        }
    };
});
//# sourceMappingURL=clustercapacitygraph.component.js.map