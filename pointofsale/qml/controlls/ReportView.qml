import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2


import "../js/Shunt.js" as Shunt
import "../js/Template.js" as Template
import "../js/SimpleSAX.js" as SimpleSAX


ScrollView {
  //anchors.fill: parent
  flickableItem.interactive: true
  function refresh(dt,print,tpl){
    canvas.refresh(dt,print,tpl);
    canvas.requestPaint();

  }
  id: scrollView
  Image{

    opacity: 0
    id: logo
    fillMode: Image.PreserveAspectFit
    source: ""
    width: 512

  }

  contentItem : Canvas {

    id:canvas

    width: (Screen.pixelDensity * 80 * 2)
    height: 15000

    property bool doPrint: false
    antialiasing: true
    property bool isConverting: false
    transform: Scale {
       xScale: 0.5
       yScale: 0.5
   }

   Timer {
     id: timeoutTimer
     interval: 500
     running: false
     repeat: false
     onTriggered: {
       timeoutTimer.stop();
       if (canvas.isConverting===false){
         canvas.isConverting=true;

         var ctx = canvas.getContext('2d');
         var imageData = ctx.getImageData(0, 0, 255, 255);
         var data = imageData.data;
         canvas.isConverting=false;
       }
     }
   }


    property var template: ""
    property var data: null

    Component.onCompleted: {

    }

    function unescapeEntities(txt){
      txt = txt.replace('&uuml;','ü');
      txt = txt.replace('&ouml;','ö');
      txt = txt.replace('&auml;','ä');
      txt = txt.replace('&szlig;','ß');
      txt = txt.replace('&Uuml;','Ü');
      txt = txt.replace('&Ouml;','Ö');
      txt = txt.replace('&Auml;','Ä');
      txt = txt.replace('&amp;','&');

      return txt;
    }


    function refresh(dt,print,tpl){


      if (typeof tpl==='undefined'){
        template = unescapeEntities(application.template);
      }else{
        template = unescapeEntities(tpl);
      }
      data = dt
      data.print = '0'

      if (print===true){
        data.print='1'
        doPrint = true
      }
      timeoutTimer.start();
    }


    function draw(context,data,drawreal){


      var sax = new SimpleSAX.SimpleSAX();
      var contextOffset = 0;

      var pixelPerMM = (512/80)/2; //Screen.pixelDensity;
      var pixelScale = pixelPerMM*10;

      var oldY = 0;
      var newY = 0;
      var maxWidth = 0;
      var lineHeight = 0;
      var item,width,padding,paddingRight,paddingLeft,paddingTop,paddingBottom,align;

      var fontStyle = "black";
      var fontSize = 0.22;

      var fontName = "sans-serif";

      var getCode39=function(data){
      	var charHash={};
      	charHash['0'] = 'nnnwwnwnn';
      	charHash['1'] = 'wnnwnnnnw';
      	charHash['2'] = 'nnwwnnnnw';
      	charHash['3'] = 'wnwwnnnnn';
      	charHash['4'] = 'nnnwwnnnw';
      	charHash['5'] = 'wnnwwnnnn';
      	charHash['6'] = 'nnwwwnnnn';
      	charHash['7'] = 'nnnwnnwnw';
      	charHash['8'] = 'wnnwnnwnn';
      	charHash['9'] = 'nnwwnnwnn';
      	charHash['A'] = 'wnnnnwnnw';
      	charHash['B'] = 'nnwnnwnnw';
      	charHash['C'] = 'wnwnnwnnn';
      	charHash['D'] = 'nnnnwwnnw';
      	charHash['E'] = 'wnnnwwnnn';
      	charHash['F'] = 'nnwnwwnnn';
      	charHash['G'] = 'nnnnnwwnw';
      	charHash['H'] = 'wnnnnwwnn';
      	charHash['I'] = 'nnwnnwwnn';
      	charHash['J'] = 'nnnnwwwnn';
      	charHash['K'] = 'wnnnnnnww';
      	charHash['L'] = 'nnwnnnnww';
      	charHash['M'] = 'wnwnnnnwn';
      	charHash['N'] = 'nnnnwnnww';
      	charHash['O'] = 'wnnnwnnwn';
      	charHash['P'] = 'nnwnwnnwn';
      	charHash['Q'] = 'nnnnnnwww';
      	charHash['R'] = 'wnnnnnwwn';
      	charHash['S'] = 'nnwnnnwwn';
      	charHash['T'] = 'nnnnwnwwn';
      	charHash['U'] = 'wwnnnnnnw';
      	charHash['V'] = 'nwwnnnnnw';
      	charHash['W'] = 'wwwnnnnnn';
      	charHash['X'] = 'nwnnwnnnw';
      	charHash['Y'] = 'wwnnwnnnn';
      	charHash['Z'] = 'nwwnwnnnn';
      	charHash['-'] = 'nwnnnnwnw';
      	charHash['.'] = 'wwnnnnwnn';
      	charHash[' '] = 'nwwnnnwnn';
      	charHash['*'] = 'nwnnwnwnn';
      	charHash['$'] = 'nwnwnwnnn';
      	charHash['/'] = 'nwnwnnnwn';
      	charHash['+'] = 'nwnnnwnwn';
      	charHash['%'] = 'nnnwnwnwn';
      	data = '*'+data.toUpperCase()+'*';
      	var result='';
      	for(var i=0; i<data.length; i++){
      		if (typeof charHash[data.charAt(i)]==='undefined'){
      			throw new Error('invalid character at position '+i);
      		}else{
      			var sequence = charHash[data.charAt(i)];
      			for (var j=0;j<9;j++){
      				var bt = sequence.charAt(j);
      				if (j%2==0){
      					bt = bt.toUpperCase();
      				}
      				result+=bt;
      			}
      		}
      		result+='n';
      	}
      	return result;
      };
      //ctx.fillStyle = "black"
      //ctx.font = "15px sans-serif";
      sax.emit = function(key,stack,tag){
        if (key==='open'){
          if (tag==='line'){
            width = 0;
            padding = 0;
            x =0;
            paddingLeft = padding;
            paddingTop = padding;
            paddingRight = padding;
            paddingBottom = padding;
          }
        }
        if (key==='tag'){
          item = stack[stack.length - 1];

          if (tag==='logo'){
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.src!=='undefined') &&
              (typeof item.attr.width!=='undefined') &&
              (typeof item.attr.height!=='undefined')
            ){

              logo.source = item.attr.src;
              context.drawImage(logo,x,0,(item.attr.width*pixelScale),(item.attr.height*pixelScale));
              contextOffset+=(item.attr.height*pixelScale)+fontSize*pixelScale;
            }
          }

          if (tag==='code39'){
            var c = getCode39(item.value);

            var w = pixelScale;
            var h = 10;

            if (typeof item.attr.width!=='undefined'){
              w =parseFloat(item.attr.width)*pixelScale;
            }
            if (typeof item.attr.height!=='undefined'){
              h = parseFloat(item.attr.height)*pixelScale;
            }

            var s = 0;
            var ci =0;
            for(ci = 0; ci<c.length; ci++){
              if (c.charAt(ci).toLowerCase()==='w'){
                s+=3;
              }else{
                s+=1;
              }
            }
            var p=w/s
            for(ci=0; ci<c.length; ci++){
              if (c.charAt(ci)==='W'){
                context.fillRect(x,newY,p*3,h);
                x+=p*3;
              }else if (c.charAt(ci)==='N'){
                context.fillRect(x,newY,p*1,h);
                x+=p*1;
              }else if (c.charAt(ci)==='w'){
                //context.fillRect(x,newY,3,10);
                x+=p*3;
              }else if (c.charAt(ci)==='n'){
                //context.fillRect(x,newY,1,10);
                x+=p*1;
              }
            }
            newY+=h;
            oldY = newY;
            //console.log('draw code 39',item.value,w,s,w/s);

          }

          if (tag==='box'){
            width = 0;
            padding = 0;
            paddingLeft = padding;
            paddingTop = padding;
            paddingRight = padding;
            paddingBottom = padding;
            align = 'L';

            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.width!=='undefined')
            ){
              width = parseFloat(item.attr.width)*pixelScale
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.padding!=='undefined')
            ){
              padding = parseFloat(item.attr.padding)*pixelScale;
              paddingLeft = padding;
              paddingTop = padding;
              paddingRight = padding;
              paddingBottom = padding;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.paddingLeft!=='undefined')
            ){
              paddingLeft = parseFloat(item.attr.paddingLeft)*pixelScale;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.paddingTop!=='undefined')
            ){
              paddingTop = parseFloat(item.attr.paddingTop)*pixelScale;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.paddingRight!=='undefined')
            ){
              paddingRight = parseFloat(item.attr.paddingRight)*pixelScale;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.paddingBottom!=='undefined')
            ){
              paddingBottom = parseFloat(item.attr.paddingBottom)*pixelScale;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.align!=='undefined')
            ){
              align = item.attr.align==='right'?'R':'L';
            }


            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.fontStyle!=='undefined')
            ){
              fontStyle = item.attr.fontStyle;
            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.fontSize!=='undefined')
            ){
              fontSize = parseFloat(item.attr.fontSize);
            }


            context.fillStyle = fontStyle;

            var fontPixelSize = pixelScale*fontSize
            if (fontPixelSize <1){
              fontPixelSize = 1
            }

            context.font = fontPixelSize+"px "+fontName;
            lineHeight = Math.max(lineHeight,fontPixelSize * 1.5);
            newY =  wrapText(
              context,
              item.value,
              x + paddingLeft,
              contextOffset + paddingTop,
              width - paddingLeft - paddingRight ,
              fontPixelSize * 1.5 ,
              align,
              drawreal) + paddingTop + paddingBottom ;
            oldY = Math.max(newY,oldY);
            x += width;
            maxWidth = Math.max(width,maxWidth);
          }else if (tag==='line'){
            contextOffset=oldY;
            x = 0;
            oldY=0;
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.fontStyle!=='undefined')
            ){
              fontStyle = item.attr.fontStyle;
            }else{

            }
            if (
              (typeof item.attr==='object') &&
              (typeof item.attr.fontSize!=='undefined')
            ){
              fontSize = parseFloat(item.attr.fontSize);
            }else{

            }
          }
        }
      }


      sax.parse(data)
      try{
        //console.log(newY,scrollView.height)
        scrollView.flickableItem.contentY = newY - scrollView.height *0.95
        //scrollView.__verticalScrollBar.value = newY //- scrollView.height *0.95
      }catch(e){
        console.log(e);
      }
      return {
        h: newY + lineHeight * 5,
        w: maxWidth
      };
    }

    function wrapText(context, text, x, y, maxWidth, lineHeight, align,drawreal) {
      var textLines = text.split("\n");
      for(var i=0;i<textLines.length;i++){
        var words = textLines[i].trim().split(' ');
        var line = '';
        for(var n = 0; n < words.length; n++) {
          var testLine = line + words[n] + ' ';
          var metrics = context.measureText(testLine);
          var testWidth = metrics.width;
          if ( ((testWidth ) > maxWidth) && (n > 0) ) {
            if (drawreal){
              fillTextAligned(context,line, x, y,maxWidth,align);
            }
            line = words[n] + ' ';
            y += lineHeight;
          } else {
            line = testLine;
          }
        }
        if (drawreal){
          fillTextAligned(context,line, x, y,maxWidth,align);
        }
        y += lineHeight;
        //context.stroke();
      }
      return y;
    }

    function fillTextAligned(context,line, x, y,maxWidth,align){
      var xOffset = 0;
      if (align==='R'){
        var metrics = context.measureText(line);
        xOffset = maxWidth-metrics.width;
      }
      context.fillText(line,x + xOffset,y);
    }


    onPaint:{

      var tplCtx = new Shunt.Shunt.Context();
      tplCtx.def('compare',function(a,b){
        return a===b;
      });
      tplCtx.def('isNot',function(a,b){
        return a!==b;
      });
      tplCtx.def('equal',function(a,b){
        return a==b;
      });
      tplCtx.def("euro", function(v) {
        return Number(v).toFixed(2) + " €"
      });
      tplCtx.def("fixed", function(v) {
        return Number(v).toFixed(2)
      });
      tplCtx.def("fixedZero", function(v) {
        return Number(v).toFixed(0)
      });
      tplCtx.def("percent", function(v) {
        return Number(v).toFixed(0) + " %"
      });

      //console.log(template);
      var tpl = new Template.Template(template,tplCtx);

      canvas.height = 15000;
      canvas.width =512;

      var ctx = canvas.getContext('2d');
      ctx.fillStyle = "white";
      ctx.fillRect(0,0,5000,5000);

      ctx.scale(2,2);
      //ctx.beginPath();
      ctx.fillStyle = "black"
      ctx.strokeStyle = "transparent"
      ctx.fillStyle = "black"
      ctx.font = "15px sans-serif";
      if ((typeof data.referenz==='undefined')&&(typeof data.reference!=='undefined')){

        data.referenz = data.reference; //backward compatibility
      }
      //      console.log(JSON.stringify(data,null,2));
      var metrics = draw(ctx,tpl.render(data),true);
      //console.log(JSON.stringify(metrics,null,2));
      //resize_canvas.getContext('2d').drawImage(orig_src, 0, 0, width, height);
      ctx.scale(0.5,0.5);
      ctx.save();
      //ctx.clearRect( 0, 0, metrics.w, metrics.h );




      if (doPrint===true){
        //canvas.width = 512
        canvas.save(data.reportnumber+'.png');
        application.posPrinter.printFile(application.printerName,data.reportnumber+'.png',metrics.h*2);
        application.posPrinter.cut(application.printerName);
        application.posPrinter.open(application.printerName);
        application.reportStore.cmd('SUM','');

      }
      doPrint=false
    }
  }
}
