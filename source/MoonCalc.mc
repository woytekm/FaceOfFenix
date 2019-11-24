// 
// Moon phase calculator from https://bitbucket.org/mike_polatoglou/moonphase/src/master/source/MoonPhaseView.mc
//
//


using Toybox.WatchUi as Ui;
using Toybox.Time as Time;
using Toybox.Graphics as Gfx;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Lang as Lang;
using Toybox.System as Sys;


	function onMoon(whichImage)
    {
		var image = whichImage;

        if(whichImage == 0) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_0 );
	    } else if(whichImage == 1) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_1 );
	    } else if(whichImage == 2) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_2 );
	    } else if(whichImage == 3) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_3 );
	    } else if(whichImage == 4) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_4 );
	    } else if(whichImage == 5) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_5 );
	    } else if(whichImage == 6) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_6 );
	    } else if(whichImage == 7) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_7 );
	    } else if(whichImage == 8) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_8 );
	    } else if(whichImage == 9) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_9 );
	    } else if(whichImage == 10) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_10 );
	    } else if(whichImage == 11) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_11 );
	    } else if(whichImage == 12) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_12 );
	    } else if(whichImage == 13) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_13 );
	    } else if(whichImage == 14) {
	    	image = Ui.loadResource( Rez.Drawables.moon_id_14 );
	    }

        return image;
    }
    
    function calcMoon()
    {
	
    	var now = Time.now();
        var date = Calendar.info(now, Time.FORMAT_SHORT);
        // date.month, date.day date.year

		var n0 = 0;
		var f0 = 0.0;
		var AG = f0;

		//current date
	    var Y1 = date.year;
	    var M1 = date.month;
	    var D1 = date.day;
	
	    var YY1 = n0;
	    var MM1 = n0;
	    var K11 = n0;
	    var K21 = n0;
	    var K31 = n0;
	    var JD1 = n0;
	    var IP1 = f0;
	    var DP1 = f0;
	
	    // calculate the Julian date at 12h UT
	    YY1 = Y1 - ( ( 12 - M1 ) / 10 ).toNumber();
	    MM1 = M1 + 9;
	    if( MM1 >= 12 ) {
	    	MM1 = MM1 - 12;
	    }
	    K11 = ( 365.25 * ( YY1 + 4712 ) ).toNumber();
	    K21 = ( 30.6 * MM1 + 0.5 ).toNumber();
	    K31 = ( ( ( YY1 / 100 ) + 49 ).toNumber() * 0.75 ).toNumber() - 38;
	
	    JD1 = K11 + K21 + D1 + 59;                  // for dates in Julian calendar
	    if( JD1 > 2299160 ) {
	    	JD1 = JD1 - K31;        				// for Gregorian calendar
		}
	
	    // calculate moon's age in days
	    IP1 = normalize( ( JD1 - 2451550.1 ) / 29.530588853 );
	    var AG1 = IP1*29.53;
	
	    var whichImage = (AG1/2).toNumber();
	    if( whichImage > 14 ) {
	    	whichImage = 14;
	    }
	    
	    var imageToDisplay = onMoon(whichImage);
	    
	    return imageToDisplay;
	    
    }
    
    function normalize( v )
	{
	    v = v - v.toNumber();
	    if( v < 0 ) {
	        v = v + 1;
		}	
	    return v;
	}
