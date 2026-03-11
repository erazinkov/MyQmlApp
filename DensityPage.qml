import QtQuick 2.0

import QtQuick.Controls

import QtGraphs

Page {
    id: densityPage
    width: parent.width

    function onProcessData(index, result, isProcess, rows, columns) {
        if (index === 0) {
            console.log(`${rows}`);
            dataModel.clear();
            rowAxis.max = rows - 1;
            columnAxis.max = columns - 1;
            var rowLabels = [];
            for (var rowIdx = 0; rowIdx < rows - 1; ++rowIdx) {
                rowLabels.push(rowIdx.toString());
            }
            rowAxis.labels = rowLabels;

            var columnLabels = [];
            for (var columnIdx = 0; columnIdx < columns - 1; ++columnIdx) {
                columnLabels.push(columnIdx.toString());
            }
            columnAxis.labels = columnLabels;
            valueAxis.max = 100;
        }
        if (!isProcess) {
            var row    = Math.floor(index / rows)
            var column = index % columns
            console.log(`${row.toString()} ${column.toString()} ${result.toString()}`);
            var max = valueAxis.max;
            if (max < result) {
                valueAxis.max = result;
            }
            dataModel.append({rowIdx: row.toString(), columnIdx: column.toString(), density: result.toString() });
        }
    }

    ListModel {
        id: dataModel
    }

    Category3DAxis {
        id: rowAxis
        min: 0
        max: 1
    }
    Category3DAxis {
        id: columnAxis
        min: 0
        max: 1
    }
    Value3DAxis {
        id: valueAxis
        min: 0
        max: 100
    }
    Bars3D {
            width: parent.width
            height: parent.height

            columnAxis: columnAxis
            rowAxis: rowAxis
            valueAxis: valueAxis

            barSpacing: Qt.size(0.0, 0.0)
            barSpacingRelative: true
            cameraZoomLevel: 95.0
            theme: GraphsTheme {
                colorScheme: GraphsTheme.ColorScheme.Light
                labelBorderVisible: true
                labelFont.pointSize: 35
                labelBackgroundVisible: true
                colorStyle: GraphsTheme.ColorStyle.RangeGradient
                baseGradients: [customGradient]
                Gradient {
                    id: customGradient
                    GradientStop { position: 0.0; color: "white" }
                    GradientStop { position: 0.2; color: "blue" }
                    GradientStop { position: 0.5; color: "green" }
                    GradientStop { position: 0.8; color: "yellow" }
                    GradientStop { position: 1.0; color: "red" }
                }
            }
            cameraPreset: Graphs3D.CameraPreset.IsometricLeftHigh
            Bar3DSeries {
                itemLabelFormat: "@colLabel, @rowLabel: @valueLabel"
                ItemModelBarDataProxy {
                    itemModel: dataModel
                    // Mapping model roles to bar series rows, columns, and values.
                    rowRole: "rowIdx"
                    columnRole: "columnIdx"
                    valueRole: "density"
                }
            }
        }

        Component.onCompleted: {
            pController.processData.connect(onProcessData);
        }
}
