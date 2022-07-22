using System.Collections.Generic;

namespace API
{
    /// <summary>
    /// Based on https://openweathermap.org/current#format
    /// </summary>
    public class Weather_Root
    {
        public int Status { get; set; }     //200, 401, 404 ...
        public string City { get; set; }

        //Weather
        public string Description { get; set; }
        public string Icon { get; set; }

        // Main
        public double Temperature { get; set; }
    }

    public static class Weather_Utils
    {
        /// <summary>
        /// Generates random city's weather
        /// </summary>
        /// <param name="pCity">The city</param>
        /// <param name="pLanguage">The language</param>
        /// <returns>The weather object</returns>
        public static Weather_Root Generate_RandomWeather(City pCity, StateManager.Language pLanguage)
        {
            Weather_Root weather = new Weather_Root();

            weather.Status = 200;
            weather.City = pCity.CityName;

            // Random weather
            switch (Utils.Rnd.RandiRange(1,7))
            {
                case 1:
                    weather.Icon = "01d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "sunny";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "ensoleillé";
                    weather.Temperature = Utils.Rnd.RandiRange(1,30);
                    break;
                case 2:
                    weather.Icon = "02d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "come clouds";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "quelques nuages";
                    weather.Temperature = Utils.Rnd.RandiRange(-10,30);
                    break;
                case 3:
                    weather.Icon = "03d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "cloudy";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "nuageux";
                    weather.Temperature = Utils.Rnd.RandiRange(-10,30);
                    break;
                case 4:
                    weather.Icon = "09d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "rainy";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "pluvieux";
                    weather.Temperature = Utils.Rnd.RandiRange(-10,30);
                    break;
                case 5:
                    weather.Icon = "11d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "stormy";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "orageux";
                    weather.Temperature = Utils.Rnd.RandiRange(1,30);
                    break;
                case 6:
                    weather.Icon = "13d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "snowy";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "neigeux";
                    weather.Temperature = Utils.Rnd.RandiRange(-20,-5);
                    break;
                case 7:
                    weather.Icon = "50d";
                    if (pLanguage == StateManager.Language.UK) weather.Description = "foggy";
                    else if (pLanguage == StateManager.Language.FR) weather.Description = "sous le brouillard";
                    weather.Temperature = Utils.Rnd.RandiRange(-10,15);
                    break;
            }

            return weather;
        }
    }
}