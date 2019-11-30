using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.SensorHistory;
using Toybox.Graphics as Gfx;
using Toybox.Time;


class FaceOfFenixApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new FaceOfFenixView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }



    function getBatteryIcon(batteryPercentage) {
   
    var BatteryIcon;
    
    if(batteryPercentage >= 90)
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery100);
     }
    else if((batteryPercentage >= 80) && (batteryPercentage <= 90))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery80);
     }
    else if((batteryPercentage >= 70) && (batteryPercentage <= 80))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery70);
     }
    else if((batteryPercentage >= 60) && (batteryPercentage <= 70))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery60);
     }
    else if((batteryPercentage >= 50) && (batteryPercentage <= 60))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery50);
     }
    else if((batteryPercentage >= 40) && (batteryPercentage <= 50))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery40);
     }
    else if((batteryPercentage >= 30) && (batteryPercentage <= 40))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery30);
     }     
    else if((batteryPercentage >= 20) && (batteryPercentage <= 30))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery20);
     }
    else if((batteryPercentage >= 10) && (batteryPercentage <= 20))
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery10);
     }
    else if(batteryPercentage < 10)
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.Battery5);
     }
    else
     {
       BatteryIcon = Ui.loadResource(Rez.Drawables.BatteryEmpty);
     }
     
     return BatteryIcon;

    }     

    function lastTempReading() {
    
      if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) 
       {
        // Set up the method with parameters
        var sensorIter = Toybox.SensorHistory.getTemperatureHistory({});
        return sensorIter.next().data;
       }
      else
       { 
        return null;
       }
    }

	function getCurrentWeekNumber() {
	    
    var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    
    var year = now.year;

	var options_start = {
    :year   => year,
    :month  => 1, // 3.x devices can also use :month => Gregorian.MONTH_MAY
    :day    => 1,
    :hour   => 0
    };

	var options_end = {
    :year   => now.year,
    :month  => now.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
    :day    => now.day,
    :hour   => 0
    };
    
 
    var current_year_start = Gregorian.moment(options_start);
    var current_year_now = Gregorian.moment(options_end);
    var year_duration = current_year_now.subtract(current_year_start);
    
    return (((((year_duration.value()/60)/60)/24)/7)+1);

	}
	
   function calculateStepGoalPercentage(stepGoal, steps)
    {
      if((stepGoal == 0) || (steps == 0))
       { 
        return 0; 
       }
       
      var percentage = (steps.toDouble() / stepGoal.toDouble()) * 100;
      return percentage.toNumber();   
    }
    
   function drawActiveWeekGoalBar(dcObj, activeMinutesWeekGoal, activeMinutes, color, screenS)
    {
 
 	 var diagramRadius = 0;
	 var diagramWidth = 9;
	 var diagramLength = 35;
	 var diagramEndDeg = 270;
	 var diagramStartDeg = diagramEndDeg + diagramLength;
	 var oneMoveBarSeg = 6;
	 
	 if(screenS == 240)
	  {
	    diagramRadius = 118;
	  }
	 else if(screenS == 280)
	  {
	    diagramRadius = 138;
	  }
     
	 dcObj.setColor(color, Graphics.COLOR_BLACK);
	 dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);
     dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - diagramWidth,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);  	 
     
     for(var i = 0; i < diagramWidth; i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-1);
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramEndDeg+1,diagramEndDeg);
      }	  
      
      if((activeMinutesWeekGoal == 0) || (activeMinutes == 0))
       {
         return;
       }
       
      var percentage = (activeMinutes.toDouble() / activeMinutesWeekGoal.toDouble()) * 100;
      percentage = percentage.toNumber();
      if(percentage > 99)
       {
        percentage = 100;
       }
      var barUnit = (diagramStartDeg.toDouble() - diagramEndDeg.toDouble()) / 100;
      var barDegrees = (percentage * barUnit);
      barDegrees = barDegrees.toNumber();
      
      for(var i = 2; i < (diagramWidth-1); i++)
        {
         dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-barDegrees-1);
        }        
    
    }
    
   function drawStepGoalBar(dcObj, stepGoal, steps, color, screenS)
    {
	 // 50 degrees to represent % step goal reached for today
	 
	 var diagramRadius = 118;
	 var diagramWidth = 9;
	 var diagramLength = 35;
	 var diagramStartDeg = 268;
	 var diagramEndDeg = diagramStartDeg - diagramLength;
	 var oneMoveBarSeg = 6;
	 
	  if(screenS == 240)
	  {
	    diagramRadius = 118;
	  }
	 else if(screenS == 280)
	  {
	    diagramRadius = 138;
	  }
     
	 dcObj.setColor(color, Graphics.COLOR_BLACK);
	 dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);
     dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - diagramWidth,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);  	 
     
     for(var i = 0; i < diagramWidth; i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-1);
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramEndDeg+1,diagramEndDeg);
      }	  
      
      if((stepGoal == 0) || (steps == 0))
       {
         return;
       }
       
      var percentage = (steps.toDouble() / stepGoal.toDouble()) * 100;
      percentage = percentage.toNumber();
      if(percentage > 99)
       {
        percentage = 100;
       }
      var barUnit = (diagramStartDeg.toDouble() - diagramEndDeg.toDouble()) / 100;
      var barDegrees = (percentage * barUnit);
      barDegrees = barDegrees.toNumber();
      
      for(var i = 2; i < (diagramWidth-1); i++)
        {
         dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-barDegrees-1);
        }     
      
      
	 }
	 
	 
    function drawMoveBar(dcObj,moveBarLevel,screenS)
	 {
	 
	 // 37 degrees for representing 5 bars = 7 - 2 (show segment boundary) = 5 degrees per segment of move bar
	 var diagramRadius = 118;
	 var diagramWidth = 9;
	 var diagramStartDeg = 203;
	 var diagramEndDeg = 165;
	 var oneMoveBarSeg = 6;
     var colorGradient = [0xff77f0, 0xff77f0, 0xff77f0, 0x8d2496, 0x6a0079];
     
      if(screenS == 240)
	  {
	    diagramRadius = 118;
	  }
	 else if(screenS == 280)
	  {
	    diagramRadius = 138;
	  }
     
	 dcObj.setColor(0xff1fbc, Graphics.COLOR_BLACK);
	 dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);
     dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - diagramWidth,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);  	 
     
     for(var i = 0; i < diagramWidth; i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-1);
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramEndDeg+1,diagramEndDeg);
      }

     var segmentStartDeg = diagramStartDeg-2;
     
     for(var i = 0; i < moveBarLevel; i++)
      {
       dcObj.setColor(colorGradient[i], Graphics.COLOR_BLACK);
       for(var j = 2; j < (diagramWidth-1); j++)
        {
         dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - j,Gfx.ARC_CLOCKWISE,segmentStartDeg,segmentStartDeg-oneMoveBarSeg);
        }    
       segmentStartDeg -= oneMoveBarSeg + 1;
            
      }
      	 
	 }
	 
	function drawDaylightDiagram(dcObj,NightEndMoment,SunriseMoment,SunsetMoment,NightStartMoment,MidnightMoment,screenS)
	{
	 
	 // 90 degrees for representing 24 hours = 1440 minutes = 16 minutes/degree
	 
	 var diagramRadius = 118;
	 var diagramWidth = 9;
	 var diagramStartDeg = 135;
	 var diagramEndDeg = 45;
	 
	 if(screenS == 240)
	  {
	    diagramRadius = 118;
	  }
	 else if(screenS == 280)
	  {
	    diagramRadius = 138;
	  }
	  
	 dcObj.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
	 dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);
     dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - diagramWidth,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramEndDeg);  
     
     for(var i = 0; i < diagramWidth; i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg,diagramStartDeg-1);
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramEndDeg+1,diagramEndDeg);
      }
     
     var Now = Time.now();
     var FromMidnightTillSunrise = SunriseMoment.value() - MidnightMoment.value();
     var FromMidnightTillSunset = SunsetMoment.value() - MidnightMoment.value();
     var FromMidnightTillNightEnd = NightEndMoment.value() - MidnightMoment.value();
     var FromMidnightTillNight = NightStartMoment.value() - MidnightMoment.value();
     var FromMidnightTillNow = Now.value() - MidnightMoment.value();
     
     System.println((FromMidnightTillSunrise.toNumber()/60)/16);
     System.println((FromMidnightTillSunset.toNumber()/60)/16);
     
     var dayStartDeg = (FromMidnightTillSunrise.toNumber()/60)/16;
     var dayEndDeg = (FromMidnightTillSunset.toNumber()/60)/16;
     
     var nightEndDeg = (FromMidnightTillNightEnd.toNumber()/60)/16;
     var nightStartDeg = (FromMidnightTillNight.toNumber()/60)/16;
      
     var nowDeg = (FromMidnightTillNow.toNumber()/60)/16;
 
     dcObj.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_BLACK);
     for(var i = 2; i < (diagramWidth-1); i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg-nightEndDeg,diagramStartDeg-nightStartDeg);
      }    
        
     dcObj.setColor(0xff8400, Graphics.COLOR_BLACK);
     for(var i = 2; i < (diagramWidth-1); i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg-dayStartDeg,diagramStartDeg-dayEndDeg);
      }    
     
     dcObj.setColor(0xff0000, Graphics.COLOR_BLACK);
     for(var i = 2; i < (diagramWidth-1); i++)
      {
        dcObj.drawArc(screenWidth/2,screenHeight/2,diagramRadius - i,Gfx.ARC_CLOCKWISE,diagramStartDeg-nowDeg+1,diagramStartDeg-nowDeg);
      }     
     
     
    }
    
   function drawHRDiagram(dcObj,color,screenS)
    {
      // 24 bars, 4 pixels wide, 20 pixels high, one pixel gap between bars - 4 hour history, 10 minutes per bar
      // 240 samples / 4h - one sample per minute
      var fourHours = new Time.Duration(14400);
      var heartRateHistory = ActivityMonitor.getHeartRateHistory(fourHours, true); //newestFirst = true
      var minValue = heartRateHistory.getMin();
      var maxValue = heartRateHistory.getMax();
      var heartRateSample;
      var goodSamples = 0;
      var intervalSum = 0;
      var sampleCounter = 0;
      var intervalAvg = 0;
      
      heartRateSample = heartRateHistory.next();      

      while(heartRateSample != null)
       {
         
         intervalSum = 0;
         goodSamples = 0;
         
         while((sampleCounter < 10) && (heartRateSample != null))
          {
            heartRateSample = heartRateHistory.next();
            if(heartRateSample != null)
             {
              if(heartRateSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE)
               {
                intervalSum += heartRateSample.heartRate;
                goodSamples++;
               }
             }
          }
          
         intervalAvg = intervalSum.toDouble() / goodSamples.toDouble();  
         intervalAvg = intervalAvg.toNumber();   
         
       }
 
      // System.println( "Samples: " + samples );
      
    } 
   

}