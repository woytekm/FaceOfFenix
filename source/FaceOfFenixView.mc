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
    var screenSize = 240;
    var screenHeight, screenWidth, mySettings;
    var FontForeground = 0xFFFFFF;
    var stepBarColor = 0x42c6ff;
    var activeBarColor = 0x00cf1b;
    var hrDiagramColor = 0xe3000b;
    
    function initialize() {
        WatchFace.initialize();
        
        var isColorSet = Application.getApp().getProperty("ForegroundColor");
        if(isColorSet == null)
         {
           Application.getApp().setProperty("ForegroundColor","0xFFFFFF");
         }
        
        mySettings = System.getDeviceSettings();
        screenHeight = mySettings.screenHeight;
        screenWidth = mySettings.screenWidth;
        
    }

    // Load your resources here
    function onLayout(dc) {
        if(screenHeight == 240)
         { 
           setLayout(Rez.Layouts.WatchFace240x240(dc));
           screenSize = 240;
         }
        else if(screenHeight == 280)
         { 
           setLayout(Rez.Layouts.WatchFace280x280(dc));
           screenSize = 280;
         }
        
        MountainIcon = Ui.loadResource(Rez.Drawables.Mountain);
        FeetIcon = Ui.loadResource(Rez.Drawables.Feet);
        HeartIcon = Ui.loadResource(Rez.Drawables.Heart);
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
        
      	var SunriseLabel = View.findDrawableById("SunriseLabel");
		SunriseLabel.setColor(FontForeground);  
    	var SunsetLabel = View.findDrawableById("SunsetLabel");
		SunsetLabel.setColor(FontForeground);

        var curLoc = getCurrentLocation();	
        
        if(curLoc == null)
         {	
           locationKnown = false;
           SunriseLabel.setText("!G  ");
           SunsetLabel.setText("    ");
          }
        else
         {
           locationKnown = true;
		   SunriseMoment = getSunriseMoment(curLoc);
		   SunriseTimeString = getSunriseTimeString(SunriseMoment);
		   SunsetMoment = getSunsetMoment(curLoc);
		   SunsetTimeString = getSunsetTimeString(SunsetMoment);
		   MidnightMoment = getTodayMidnightMoment();
		
		   NightEndMoment = getNightEndMoment(curLoc);
		   NightStartMoment = getNightStartMoment(curLoc);
           SunriseLabel.setText(SunriseTimeString);
           SunsetLabel.setText(SunsetTimeString);         
          }
          
        
     
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var currHour = hours;
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

        // Update the view
        var TimeLabel;
        
        //if( (currHour > 9) || (Application.getApp().getProperty("UseMilitaryFormat")) )
        // {
        TimeLabel = View.findDrawableById("TimeCenteredLabel");
        // }
        //else
        // {
        //  TimeLabel = View.findDrawableById("TimeShiftedLabel");
        // }
         
        TimeLabel.setColor(0xFFFFFF);
        //TimeLabel.setText("  :  ");
        TimeLabel.setText(timeString);
       
        var temp = FaceOfFenixApp.lastTempReading().toNumber();        
        var TempLabel = View.findDrawableById("TempLabel");
		TempLabel.setColor(FontForeground);  
		TempLabel.setText(Lang.format("$1$°",[temp]));
		
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var month = now.month;
		var day_of_week = now.day_of_week;

		var month_names = ["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE", 
		                    "JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
		                    
		var weekdays = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"];                    
        var DayLabel = View.findDrawableById("DayLabel");
		DayLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
		DayLabel.setText(weekdays[day_of_week-1]);

        var MonthLabel = View.findDrawableById("MonthLabel");
		MonthLabel.setColor(FontForeground);
		MonthLabel.setText(month_names[month-1]);
		
		var currWeek = FaceOfFenixApp.getCurrentWeekNumber();
		var currWeekString = Lang.format("($1$)",[currWeek]);
		
		var ISOWeekLabel = View.findDrawableById("ISOWeekLabel");
		ISOWeekLabel.setColor(FontForeground);
		ISOWeekLabel.setText(currWeekString);

        var DayNumberLabel = null;
        var day = now.day;
		DayNumberLabel = View.findDrawableById("DayNumber");		 
	    DayNumberLabel.setColor(FontForeground);
		DayNumberLabel.setText(Lang.format("$1$",[day]));
        
        var AltitudeLabel = View.findDrawableById("AltitudeLabel");
		AltitudeLabel.setColor(FontForeground);
        var Altitude = Toybox.Activity.getActivityInfo().altitude.toNumber();		
		AltitudeLabel.setText(Lang.format("$1$m",[Altitude]));
		
		var BatteryLabel = View.findDrawableById("BatteryLabel");
		BatteryLabel.setColor(FontForeground);
		//System.println(Application.getApp().getProperty("ForegroundColor"));
        var batStatus = System.getSystemStats().battery.toNumber();		
		BatteryLabel.setText(Lang.format("$1$%",[batStatus]));	
		BatteryIcon = FaceOfFenixApp.getBatteryIcon(batStatus);	
		
		var activityMonitorInfo = Toybox.ActivityMonitor.getInfo();
		
		var DistanceLabel = View.findDrawableById("DistanceLabel");
		DistanceLabel.setColor(FontForeground);
        var Distance = (activityMonitorInfo.distance.toDouble()/100)/1000;
        if(Distance < 1)
         {
          Distance = (activityMonitorInfo.distance.toDouble()/100);
          DistanceLabel.setText(Lang.format("$1$m",[Distance.format("%1d")]));
          //DistanceLabel.setText("199.88km");
         }
        else
         {
		   DistanceLabel.setText(Lang.format("$1$km",[Distance.format("%.2f")]));	
		 }
		
		var StepsLabel = View.findDrawableById("StepsLabel");
		StepsLabel.setColor(FontForeground);
        var Steps = activityMonitorInfo.steps;
		StepsLabel.setText(Lang.format("$1$",[Steps]));			
		//StepsLabel.setText("99888");
		
		var StepsGoalLabel = View.findDrawableById("StepsGoalLabel");
		StepsGoalLabel.setColor(stepBarColor);
        var StepsGoal = activityMonitorInfo.stepGoal;
        var StepPercentage = FaceOfFenixApp.calculateStepGoalPercentage(StepsGoal,Steps);
		StepsGoalLabel.setText(Lang.format("$1$",[StepPercentage]));		
		
		var ActivityGoalLabel = View.findDrawableById("ActiveGoalLabel");
		ActivityGoalLabel.setColor(activeBarColor);
        var ActivityGoal = activityMonitorInfo.activeMinutesWeekGoal;
        var ActivityPercentage = FaceOfFenixApp.calculateStepGoalPercentage(ActivityGoal,activityMonitorInfo.activeMinutesWeek.total);
		ActivityGoalLabel.setText(Lang.format("$1$",[ActivityPercentage]));		
			
		var CaloriesLabel = View.findDrawableById("CaloriesLabel");
		CaloriesLabel.setColor(FontForeground);
		var Calories = activityMonitorInfo.calories;
		CaloriesLabel.setText(Lang.format("$1$KC",[Calories]));
				
		var CurrentHRLabel = View.findDrawableById("CurrentHRLabel");
		CurrentHRLabel.setColor(FontForeground);
		var heartRateHistory = ActivityMonitor.getHeartRateHistory(1, true);
		var CurrentHRSample = heartRateHistory.next();
        var CurrentHR = CurrentHRSample.heartRate;
		if((CurrentHRSample == ActivityMonitor.INVALID_HR_SAMPLE) || (CurrentHR == 255))
		 {
		  CurrentHRLabel.setText("--");
		 }
		else
		 {
		  //CurrentHRLabel.setText("255");
		  CurrentHRLabel.setText(Lang.format("$1$",[CurrentHR]));		
		 }
		
		 
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        if(screenSize == 240)
         {
           dc.drawBitmap(105,14,calcMoon());
           dc.drawBitmap(23,42,MountainIcon);
           dc.drawBitmap(184,41,BatteryIcon);
           dc.drawBitmap(160,185,FeetIcon);
           dc.drawBitmap(205,156,HeartIcon);
         }
        else if(screenSize == 280)
         {
           dc.drawBitmap(126,17,calcMoon());
           dc.drawBitmap(25,50,MountainIcon);
           dc.drawBitmap(218,50,BatteryIcon);
           dc.drawBitmap(180,220,FeetIcon);
           dc.drawBitmap(235,183,HeartIcon);        
         }
        
        if(locationKnown == true)
         {
	      FaceOfFenixApp.drawDaylightDiagram(dc,NightEndMoment,SunriseMoment,SunsetMoment,NightStartMoment,MidnightMoment,screenSize);
	     }
	     
	    FaceOfFenixApp.drawMoveBar(dc, activityMonitorInfo.moveBarLevel,screenSize);
	    FaceOfFenixApp.drawStepGoalBar(dc, activityMonitorInfo.stepGoal, activityMonitorInfo.steps, stepBarColor,screenSize);
	    FaceOfFenixApp.drawActiveWeekGoalBar(dc, activityMonitorInfo.activeMinutesWeekGoal, activityMonitorInfo.activeMinutesWeek.total, activeBarColor, screenSize);
	    FaceOfFenixApp.drawHRDiagram(dc,hrDiagramColor,screenSize,View,FontForeground);
	       
	    
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
