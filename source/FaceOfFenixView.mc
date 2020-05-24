using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor as AM;

using Toybox.Position;
using Toybox.System;

class FaceOfFenixView extends WatchUi.WatchFace {


    var MountainIcon;
    var BatteryIcon;
    var FeetIcon;
    var HeartIcon;
    var BTIcon;
    var NotifIcon;
    var mySettings;
    var FontForeground = 0xFFFFFF;
    var stepBarColor = 0x42c6ff;
    var floorBarColor = 0xfbff05;
    var activeBarColor = 0x00cf1b;
    var hrDiagramColor = 0xe3000b;
    
    function initialize() {
        WatchFace.initialize();        
        mySettings = System.getDeviceSettings();
    }

    // Load your resources here
    function onLayout(dc) {
        if(mySettings.screenHeight == 240)
         { 
           setLayout(Rez.Layouts.WatchFace240x240(dc));
         }
        else if(mySettings.screenHeight == 280)
         { 
           setLayout(Rez.Layouts.WatchFace280x280(dc));
         }
         
         MountainIcon = Ui.loadResource(Rez.Drawables.Mountain);
         FeetIcon = Ui.loadResource(Rez.Drawables.Feet);
         HeartIcon = Ui.loadResource(Rez.Drawables.Heart);
         BTIcon = Ui.loadResource(Rez.Drawables.BT);
         NotifIcon = Ui.loadResource(Rez.Drawables.Mail);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
 
    }
        
    // Update the view
    function onUpdate(dc) {
    
        var locationKnown = false;
        var SunriseMoment = null;
        var SunriseTimeString = null;
        var SunsetMoment = null;
        var SunsetTimeString = null;
        var MidnightMoment = null;
        var NightEndMoment = null;
        var NightStartMoment = null;
        
        var curLoc = getCurrentLocation();	
        
        if(curLoc == null)
         {	
           locationKnown = false;
           FaceOfFenixApp.displayLabel("SunriseLabel",FontForeground,"!G  ");
           FaceOfFenixApp.displayLabel("SunsetLabel",FontForeground,"    ");
          }
        else
         {
           locationKnown = true;
		   SunriseMoment = getSunMoment(curLoc,SUNRISE);
		   SunriseTimeString = getEventTimeString(SunriseMoment);
		   SunsetMoment = getSunMoment(curLoc,SUNSET);
		   SunsetTimeString = getEventTimeString(SunsetMoment);
		   
		   MidnightMoment = Time.today();
		   		   
		   NightEndMoment = getSunMoment(curLoc,NIGHT_END);
		   NightStartMoment = getSunMoment(curLoc,NIGHT);
		   
		   FaceOfFenixApp.displayLabel("SunriseLabel",FontForeground,SunriseTimeString);
		   FaceOfFenixApp.displayLabel("SunsetLabel",FontForeground,SunsetTimeString);
          }       
     
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$:$2$";
                hours = hours.format("%02d");
            }
        }
        
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);        
        FaceOfFenixApp.displayLabel("TimeCenteredLabel",FontForeground,timeString);
       
        var sensorIter = Toybox.SensorHistory.getTemperatureHistory({});
        var temp = sensorIter.next().data.toNumber(); 
        FaceOfFenixApp.displayLabel("TempLabel",FontForeground,temp.format("%3d")+"°");
       		
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var month = now.month;
		var day_of_week = now.day_of_week;

		var month_names = ["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE", 
		                    "JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
		                    
		var weekdays = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"];                    
		
		FaceOfFenixApp.displayLabel("DayLabel",FontForeground,weekdays[day_of_week-1]);
        FaceOfFenixApp.displayLabel("MonthLabel",FontForeground,month_names[month-1]);
		
		var currWeek = FaceOfFenixApp.getCurrentWeekNumber();
        FaceOfFenixApp.displayLabel("ISOWeekLabel",FontForeground,"("+currWeek.format("%1d")+")");

        var day = now.day;
        FaceOfFenixApp.displayLabel("DayNumber",FontForeground,day.format("%2d"));
        
        FaceOfFenixApp.displayLabel("AltitudeLabel",FontForeground,Toybox.Activity.getActivityInfo().altitude.format("%4d")+"m");
		
        var batStatus = System.getSystemStats().battery.toNumber();				
		FaceOfFenixApp.displayLabel("BatteryLabel",FontForeground,batStatus.format("%3d")+"%");
		BatteryIcon = FaceOfFenixApp.getBatteryIcon(batStatus);	
		
		var activityMonitorInfo = Toybox.ActivityMonitor.getInfo();
		
        var Distance = (activityMonitorInfo.distance.toDouble()/100)/1000;
        
        if(Distance < 1)
         {
          Distance = (activityMonitorInfo.distance.toDouble()/100);
          FaceOfFenixApp.displayLabel("DistanceLabel",FontForeground,Distance.format("%3d")+"m");
         }
        else
         {
		  FaceOfFenixApp.displayLabel("DistanceLabel",FontForeground,Distance.format("%3.2f")+"km");	
		 }
	    	
		FaceOfFenixApp.displayLabel("StepsLabel",FontForeground,activityMonitorInfo.steps.format("%5d"));
		
        var StepPercentage = FaceOfFenixApp.calculateStepGoalPercentage(activityMonitorInfo.stepGoal,activityMonitorInfo.steps);		
		FaceOfFenixApp.displayLabel("StepsGoalLabel",stepBarColor,StepPercentage.format("%3d"));

        var ActivityPercentage = FaceOfFenixApp.calculateStepGoalPercentage(activityMonitorInfo.activeMinutesWeekGoal,activityMonitorInfo.activeMinutesWeek.total);		
		FaceOfFenixApp.displayLabel("ActiveGoalLabel",activeBarColor,ActivityPercentage.format("%3d"));
			
		FaceOfFenixApp.displayLabel("CaloriesLabel",FontForeground,activityMonitorInfo.calories.format("%5d")+"KC");
				
		var heartRateHistory = ActivityMonitor.getHeartRateHistory(1, true);
		
		var CurrentHRSample = heartRateHistory.next();
		
		if((CurrentHRSample == ActivityMonitor.INVALID_HR_SAMPLE) || (CurrentHRSample.heartRate == 255))
		 {
		  FaceOfFenixApp.displayLabel("CurrentHRLabel",FontForeground,"--");
		 }
		else
		 {
		  FaceOfFenixApp.displayLabel("CurrentHRLabel",FontForeground,CurrentHRSample.heartRate.format("%3d"));	
		 }

        var btConn = false;
        var settings = System.getDeviceSettings();
                
        if (settings has :connectionInfo) {
    		btConn = settings.connectionInfo.get(:bluetooth).state == System.CONNECTION_STATE_CONNECTED;
    	}
    	else {
    		btConn = settings.getDeviceSettings().phoneConnected;
    	}        
    	
    	if((settings.notificationCount > 0) && btConn)
    	 {		
          FaceOfFenixApp.displayLabel("NotificationsLabel",FontForeground,settings.notificationCount.format("%2d"));
		 }
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
  
        
        if(mySettings.screenHeight == 240)
         {

           dc.drawBitmap(105,14,calcMoon());
           dc.drawBitmap(23,42,MountainIcon);                      
           dc.drawBitmap(184,41,BatteryIcon);
           dc.drawBitmap(160,185,FeetIcon);
           dc.drawBitmap(205,156,HeartIcon);
           
           if(btConn)
            {
              dc.drawBitmap(17,57,BTIcon);
              if(settings.notificationCount > 0)
               { 
                dc.drawBitmap(55,60,NotifIcon);
               } 
            }
         }
        else if(mySettings.screenHeight == 280)
         {
           dc.drawBitmap(126,17,calcMoon());
           dc.drawBitmap(25,50,MountainIcon);
           dc.drawBitmap(218,50,BatteryIcon);
           dc.drawBitmap(180,220,FeetIcon);
           dc.drawBitmap(235,183,HeartIcon); 
           
           if(btConn)
            {
              dc.drawBitmap(20,69,BTIcon);
              if(settings.notificationCount > 0)
               {
                dc.drawBitmap(58,72,NotifIcon);
               }
            }
 
            
         }
        
        if(locationKnown == true)
         {
	      FaceOfFenixApp.drawDaylightDiagram(dc,NightEndMoment,SunriseMoment,SunsetMoment,NightStartMoment,MidnightMoment,mySettings.screenWidth,mySettings.screenHeight);
	     }
	     
	    FaceOfFenixApp.drawMoveBar(dc, activityMonitorInfo.moveBarLevel,mySettings.screenWidth,mySettings.screenHeight);
	    FaceOfFenixApp.drawStepGoalBar(dc,activityMonitorInfo.stepGoal, activityMonitorInfo.steps,activityMonitorInfo.floorsClimbedGoal,activityMonitorInfo.floorsClimbed,stepBarColor,floorBarColor,mySettings.screenWidth,mySettings.screenHeight);
	    FaceOfFenixApp.drawActiveWeekGoalBar(dc,activityMonitorInfo.activeMinutesWeekGoal,activityMonitorInfo.activeMinutesWeek.total,activeBarColor,mySettings.screenWidth,mySettings.screenHeight);
	    FaceOfFenixApp.drawHRDiagram(dc,hrDiagramColor,mySettings.screenWidth,View,FontForeground);
	     
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
