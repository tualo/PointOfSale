import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2


import "../../controlls"
import "../../styles"

Rectangle {
  property string modeText: 'GutscheinEinloesen'
  width: parent.width
  height: parent.height
  function cmd(cmdtype, val, input) {
    if (cmdtype === 'BACK') {
      if (application.reportStore.referenzString.length > 0) {
        application.reportStore.referenzString = application.reportStore.referenzString.substring(0, application.reportStore.referenzString.length - 1);
      }
      return;
    }

    if (cmdtype === 'CANCLE LAST') {
      application.reportStore.currentMode = 'amount';
    }

    if (cmdtype === 'ENTER') {
      /*
      application.reportStore.refItem.referenz = application.reportStore.referenzString;
      application.reportStore.currentMode = 'amount';
      application.reportStore.add(application.reportStore.refItem, true);
      */
      application.remote.shortPost({
        id: application.reportStore.referenzString,
        cmp: 'cmp_gutscheine',
        page: 'ajax/gutschein/plugin',
        objid: '',
      }, function(err,res){
        if (err){
          application.displayMessage("Der Code kann nicht geprüft werden");
        }else{
          if (res.success === true){


            application.reportStore.refItem.referenzphp = '/cmp/cmp_gutscheine/plugins/gutschein/save.php';

            application.reportStore.refItem.referenz = application.reportStore.referenzString;
            application.reportStore.refItem.brutto_preis = res.data.value*-1;
            application.reportStore.add(application.reportStore.refItem, true);
            application.reportStore.calcPos();
            application.reportStore.currentMode = 'amount';


          }else if (typeof res.message==='string') {
            application.displayMessage(res.message);
          }else if (typeof res.msg==='string') {
            application.displayMessage(res.msg);
          }

        }
        if (err){
          application.logger.error((new Date()).toISOString()+" - "+JSON.stringify(err,null,1));
        }else{
          application.logger.debug((new Date()).toISOString()+" - "+JSON.stringify(res,null,1));
        }
      });
    }

    if (cmdtype === 'NUM') {
      if (application.reportStore.number === -1) {
        application.reportStore.referenzString += val + ""
        return;
      }
    }
  }

  Text {
    color: "white"
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Gutscheincode: " + application.reportStore.referenzString
  }

}
