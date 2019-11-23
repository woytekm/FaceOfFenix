using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi as Ui;

using Toybox.Position;
using Toybox.System;

class FaceOfFenixView extends WatchUi.WatchFace {


    var MountainIcon;
    var BatteryIcon;
    var screenHeight, screenWidth, mySettings;
    
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
        if(screenHeight == screenWidth == 240)
         { 
           setLayout(Rez.Layouts.WatchFace240x240(dc));
         }

        MountainIcon = Ui.loadResource(Rez.Drawables.Mountain);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
 
    }

        
    // Update the view
    function onUpdate(dc) {
    

      	var SunriseLabel = View.findDrawableById("SunriseLabel");
		SunriseLabel.setColor(Application.getApp().getProperty("ForegroundColor"));  
    	var SunsetLabel = View.findDrawableById("SunsetLabel");
		SunsetLabel.setColor(Application.getApp().getProperty("ForegroundColor"));

        var curLoc = getCurrentLocation();		
		var SunriseMoment = getSunriseMoment(curLoc);
		var SunriseTimeString = getSunriseTimeString(SunriseMoment);
		var SunsetMoment = getSunsetMoment(curLoc);
		var SunsetTimeString = getSunsetTimeString(SunsetMoment);
		var MidnightMoment = getTodayMidnightMoment();
		
		var NightEndMoment = getNightEndMoment(curLoc);
		var NightStartMoment = getNightStartMoment(curLoc);
		
		
        SunriseLabel.setText(SunriseTimeString);
        SunsetLabel.setText(SunsetTimeString);         
     
        
     
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
		TempLabel.setColor(Application.getApp().getProperty("ForegroundColor"));  
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
		MonthLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
		MonthLabel.setText(month_names[month-1]);
		
		var currWeek = FaceOfFenixApp.getCurrentWeekNumber();
		var currWeekString = Lang.format("($1$)",[currWeek]);
		
		var ISOWeekLabel = View.findDrawableById("ISOWeekLabel");
		ISOWeekLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
		ISOWeekLabel.setText(currWeekString);
		
		var DayNumberLabel = View.findDrawableById("DayNumber");
		DayNumberLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
		DayNumberLabel.setText(Lang.format("$1$",[now.day]));
        
        var AltitudeLabel = View.findDrawableById("AltitudeLabel");
		AltitudeLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
        var Altitude = Toybox.Activity.getActivityInfo().altitude.toNumber();		
		AltitudeLabel.setText(Lang.format("$1$m",[Altitude]));
		
		var BatteryLabel = View.findDrawableById("BatteryLabel");
		BatteryLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
		//System.println(Application.getApp().getProperty("ForegroundColor"));
        var batStatus = System.getSystemStats().battery.toNumber();		
		BatteryLabel.setText(Lang.format("$1$%",[batStatus]));	
		BatteryIcon = FaceOfFenixApp.getBatteryIcon(batStatus);	
						
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        dc.drawBitmap(29,42,MountainIcon);
        dc.drawBitmap(184,41,BatteryIcon);
	    FaceOfFenixApp.drawDaylightDiagram(dc,NightEndMoment,SunriseMoment,SunsetMoment,NightStartMoment,MidnightMoment);
        
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
