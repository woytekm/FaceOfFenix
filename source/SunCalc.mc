/*

Monkey C library to calculate Dusk, Dawn, Sunset, Sunrise, Blue Hour, etc.
Copyright (C) 2016 Harald Hoyer

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

*/

//
// This code is part of [SunCalc](https://github.com/haraldh/SunCalc), an opensource
// widget written by Harald Hoyer (Github: [haraldh](https://github.com/haraldh)).
// The complete project is located on Github at: https://github.com/haraldh/SunCalc
//

using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Position;
using Toybox.System;
using Toybox.Activity;
using Toybox.Time.Gregorian;
using Toybox.Lang;


enum {
    NIGHT_END,
    NAUTICAL_DAWN,
    DAWN,
    BLUE_HOUR_AM,
    SUNRISE,
    SUNRISE_END,
    GOLDEN_HOUR_AM,
    NOON,
    GOLDEN_HOUR_PM,
    SUNSET_START,
    SUNSET,
    BLUE_HOUR_PM,
    DUSK,
    NAUTICAL_DUSK,
    NIGHT,
    NUM_RESULTS
}

class SunCalc {

    hidden const PI   = Math.PI,
        RAD  = Math.PI / 180.0,
        PI2  = Math.PI * 2.0,
        DAYS = Time.Gregorian.SECONDS_PER_DAY,
        J1970 = 2440588,
        J2000 = 2451545,
        J0 = 0.0009;

    hidden const TIMES = [
        -18 * RAD,
        -12 * RAD,
        -6 * RAD,
        -4 * RAD,
        -0.833 * RAD,
        -0.3 * RAD,
        6 * RAD,
        null,
        6 * RAD,
        -0.3 * RAD,
        -0.833 * RAD,
        -4 * RAD,
        -6 * RAD,
        -12 * RAD,
        -18 * RAD
        ];

    var lastD, lastLng;
    var n, ds, M, sinM, C, L, sin2L, dec, Jnoon;

    function initialize() {
        lastD = null;
        lastLng = null;
    }

    function fromJulian(j) {
        return new Time.Moment((j + 0.5 - J1970) * DAYS);
    }

    function round(a) {
        if (a > 0) {
            return (a + 0.5).toNumber().toFloat();
        } else {
            return (a - 0.5).toNumber().toFloat();
        }
    }

    // lat and lng in radians
    function calculate(moment, lat, lng, what) {
        var d = moment.value().toDouble() / DAYS - 0.5 + J1970 - J2000;
        if (lastD != d || lastLng != lng) {
            n = round(d - J0 + lng / PI2);
//          ds = J0 - lng / PI2 + n;
            ds = J0 - lng / PI2 + n - 1.1574e-5 * 68;
            M = 6.240059967 + 0.0172019715 * ds;
            sinM = Math.sin(M);
            C = (1.9148 * sinM + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M)) * RAD;
            L = M + C + 1.796593063 + PI;
            sin2L = Math.sin(2 * L);
            dec = Math.asin( 0.397783703 * Math.sin(L) );
            Jnoon = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
            lastD = d;
            lastLng = lng;
        }

        if (what == NOON) {
            return fromJulian(Jnoon);
        }

        var x = (Math.sin(TIMES[what]) - Math.sin(lat) * Math.sin(dec)) / (Math.cos(lat) * Math.cos(dec));

        if (x > 1.0 || x < -1.0) {
            return null;
        }

        var ds = J0 + (Math.acos(x) - lng) / PI2 + n - 1.1574e-5 * 68;

        var Jset = J2000 + ds + 0.0053 * sinM - 0.0069 * sin2L;
        if (what > NOON) {
            return fromJulian(Jset);
        }

        var Jrise = Jnoon - (Jset - Jnoon);

        return fromJulian(Jrise);
    }
}


function getCurrentLocation()
 {
 
  var gotFromProperty = 0;
  var curLoc = Activity.getActivityInfo().currentLocation;
  if(curLoc == null)
    {
      var curLocDict = FaceOfFenixApp.getProperty("location");
      
      if(curLocDict == null){
        return null;
        }
      var RestoredLocation = new Position.Location({:latitude => curLocDict[0],:longitude => curLocDict[1],:format => :degrees});       
      curLoc = RestoredLocation;
      gotFromProperty = 1; 
     }
    
    if(!gotFromProperty)
     {
      var curLocDeg = curLoc.toDegrees();
      FaceOfFenixApp.setProperty("location", curLocDeg);
     }
     
    return curLoc;
     
   }  
 

function getNightEndMoment(curLoc)
 {
    if(curLoc == null)
      { return null;}      
    var long = curLoc.toRadians()[1]; 
    var lat = curLoc.toRadians()[0]; 
    var today = new Time.Moment(Time.today().value());
    var SunCalculator = new SunCalc();
    var SunsetMoment = SunCalculator.calculate(today, lat, long, NIGHT_END);   
 
    return SunsetMoment;
 }
 
function getNightStartMoment(curLoc)
 {
    if(curLoc == null)
      { return null;}      
    var long = curLoc.toRadians()[1]; 
    var lat = curLoc.toRadians()[0]; 
    var today = new Time.Moment(Time.today().value());
    var SunCalculator = new SunCalc();
    var SunsetMoment = SunCalculator.calculate(today, lat, long, NIGHT);   
 
    return SunsetMoment;
 }
 

function getSunsetMoment(curLoc)
 {
    if(curLoc == null)
      { return null;}      
    var long = curLoc.toRadians()[1]; 
    var lat = curLoc.toRadians()[0]; 
    var today = new Time.Moment(Time.today().value());
    var SunCalculator = new SunCalc();
    var SunsetMoment = SunCalculator.calculate(today, lat, long, SUNSET);   
 
    return SunsetMoment;
 }
 

function getSunsetTimeString(SunsetMoment)
 {
    if(SunsetMoment == null)
     {return " ";}
    var SunsetTime = Gregorian.info(SunsetMoment, Time.FORMAT_MEDIUM);
    SunsetTime.min = SunsetTime.min.format("%02d");
    var SunsetTimeStr = Lang.format("$1$:$2$",[SunsetTime.hour, SunsetTime.min]);
    return SunsetTimeStr;
 }

function getSunriseMoment(curLoc)
 {
    if(curLoc == null)
     { return null;}   
    var long = curLoc.toRadians()[1]; 
    var lat = curLoc.toRadians()[0]; 
    var today = new Time.Moment(Time.today().value());
    var SunCalculator = new SunCalc();
    var SunriseMoment = SunCalculator.calculate(today, lat, long, SUNRISE);  
    return SunriseMoment;
 }
 
function getSunriseTimeString(SunriseMoment)
 {
    if(SunriseMoment == null)
     {return "!G";}
    var SunriseTime = Gregorian.info(SunriseMoment, Time.FORMAT_MEDIUM); 
    SunriseTime.min = SunriseTime.min.format("%02d");
    var SunriseTimeStr = Lang.format("$1$:$2$",[SunriseTime.hour, SunriseTime.min]);
    return SunriseTimeStr;  
 }
 
function getTodayMidnightMoment()
 {
 
   var NowMoment = new Time.Moment(Time.today().value());
   var NowGregorianInfo = Gregorian.info(NowMoment, Time.FORMAT_MEDIUM);
 
   var todayMidnight = {
    :year   => NowGregorianInfo.year,
    :month  => NowGregorianInfo.month, // 3.x devices can also use :month => Gregorian.MONTH_MAY
    :day    => NowGregorianInfo.day,
    :hour   => 0,  // here we have a problem with daylight saving - looks like a Connect IQ bug
    :minute => 0,
    :second => 0
    };
  
   var MidnightMoment = Gregorian.moment(todayMidnight);

   return MidnightMoment;

 }