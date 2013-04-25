function hideWarning()
{
	// Hide the splash screen.
	document.getElementById('content-warning').style.display='none';
}

function acceptWarning()
{
	// Set the cookie so we don't see it again.
	var cookie_date = new Date();
	cookie_date.setDate(cookie_date.getDate() + 7);

	var value = "yeah";
	var cookie_value=escape(value) + ((cookie_date==null) ? "" : "; expires="+cookie_date.toUTCString());

	document.cookie= "acceptedWarning=" + cookie_value;

	// Hide the screen.
	hideWarning();
}

function checkWarning()
{
	var cookie_name = "acceptedWarning";
	var cookie_value = document.cookie;
	var cookie_start = cookie_value.indexOf(" " + cookie_name + "=");

	console.log("Hiya " + cookie_value);

	if (cookie_start == -1)
	{
		cookie_start = cookie_value.indexOf(cookie_name + "=");
	}

	console.log("cookie_start " + cookie_start);

	if (cookie_start == -1)
	{
		cookie_value = null;
	}
	else
	{
		cookie_start = cookie_value.indexOf("=", cookie_start) + 1;
		var cookie_end = cookie_value.indexOf(";", cookie_start);

		if (cookie_end == -1)
		{
			cookie_end = cookie_value.length;
		}

		cookie_value = unescape(cookie_value.substring(cookie_start,cookie_end));

		console.log("cookie_value " + cookie_value);
	}

	// If we have the cookie, then hide it.
	if (cookie_value === "yeah")
	{
		// Hide the screen.
		hideWarning();
	}
}

checkWarning();
