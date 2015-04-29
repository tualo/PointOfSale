import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import "../../js/Template.js" as Template
ScrollView {
  id: scrollview

  property string defaultBackgroundColor: '#111122'

  function addItem(item) {
    gridModel.append(item);
  }

  function addList(list) {
    gridModel.clear();

    for (var i = 0, m = list.length; i < m; i++) {
      addItem(prepareItem(list[i]));
    }
    cRows = Math.ceil(list.length/columns)
  }

  function prepareItem(entry) {
    var item = {
      isVisible: (typeof entry !== 'undefined' && entry !== null),
      displayText: rendered(entry),
      entry: entry,
    }
    item.backgroundColor = item.isVisible ? ((typeof entry.displayBackgroundColor !== 'undefined') ? entry.displayBackgroundColor : defaultBackgroundColor) : "transparent";
    item.textColor = item.isVisible ? "white" : "transparent";
    item.outlineColor = item.isVisible ? "black" : "transparent";

    return item
  }

  function rendered(item) {
    var tmpl = new Template.Template(template);
    tmpl.ctx.def("euro", function(v) {
      return Number(v).toFixed(2) + " €"
    });
    if (typeof item === 'object') {
      return tmpl.render(item);
    } else {
      return ""
    }
  }

  property int itemWidth: Math.round((width - spacing * (columns - 1)) / columns)
  property int itemHeight: Math.round((height - spacing * (rows - 1)) / rows)
  property int itemRadius: 5
  property int offset: 0

  property string template: "{text}"
  signal selected(var item)

  property alias columns: grid.columns
  property int rows: 2
  property alias cRows: grid.rows
  property alias spacing: grid.spacing

  Grid {
    id: grid

    spacing: 8
    columns: 2
    rows: 2

    ListModel {
      id: gridModel
    }

    Repeater {
      model: gridModel
      Rectangle {
        radius: scrollview.itemRadius
        width: scrollview.itemWidth
        height: (txt.height< scrollview.itemHeight)?scrollview.itemHeight:txt.height
        color: backgroundColor
        clip: true
        opacity: mouse.pressed ? 0.5 : (isVisible ? 1 : 0)
        Behavior on opacity {
          OpacityAnimator {
            easing.type: Easing.InCubic;
            duration: 50
          }
        }
        Text {
          id: txt
          font.pixelSize: mainStyle.font.size
          width: scrollview.itemWidth - spacing
          //height: grid.itemHeight - spacing
          color: textColor
          anchors.centerIn: parent
          wrapMode: Text.Wrap
          elide: Text.ElideMiddle
          text: displayText
          antialiasing: true
          style: Text.Outline
          styleColor: outlineColor
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          //clip: true
        }

        MouseArea {
          id: mouse
          anchors.fill: parent
          anchors.margins: -10
          onClicked: {
            console.log(mainStyle.font.size);
            var item = gridModel.get(index);
            selected(item.entry);
          }
        }

      }
    }
  }
}
