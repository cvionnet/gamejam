using System.Collections.Generic;

namespace API
{
    public class City
    {
        public string CountryName { get; set; }
        public string CityName { get; set; }
        public float Longitude { get; set; }    // x coordinates on the map
        public float Latitude { get; set; }    // y coordinates on the map
        public Weather_Root CityWeather { get; set; }    // Contains the weather of the city

        private static List<City> _listAllCities = new List<City>();

        //*-------------------------------------------------------------------------*//

        /// <summary>
        /// Constructor
        /// </summary>
        public City(string pCountry, string pCity, float pLongitude, float pLatitude)
        {
            CountryName = pCountry;
            CityName = pCity;
            Longitude = pLongitude;
            Latitude = pLatitude;
        }

        /// <summary>
        /// Select a random list of cities from the whole list
        /// </summary>
        /// <param name="pQuantity">How many cities to select</param>
        public static List<City> Select_RandomCities(int pQuantity)
        {
            int count;
            bool cityAdded;
            List<City> listRandomCities = new List<City>();

            for (int i = 0; i < pQuantity; i++)
            {
                // Only add a city that is not already in the list
                count = 0;
                cityAdded = false;
                while (!cityAdded && count <= 10)
                {
                    // Get a random city
                    City city = _listAllCities[Utils.Rnd.RandiRange(0, _listAllCities.Count-1)];

                    if(!listRandomCities.Contains(city))
                    {
                        listRandomCities.Add(city);
                        cityAdded = true;
                    }

                    count++;
                }
            }

            return listRandomCities;
        }

        /// <summary>
        /// Load the whole list of cities
        /// </summary>
        /// <param name="pLanguage">The language</param>
        public static void Load_Game_Cities(StateManager.Language pLanguage)
        {
            switch (pLanguage)
            {
                case StateManager.Language.UK :
                    _listAllCities.Add(new City("Afghanistan","Kabul",1262,456));
                    _listAllCities.Add(new City("Algeria","Algiers",916,459));
                    _listAllCities.Add(new City("Argentina","Buenos Aires",601,899));
                    _listAllCities.Add(new City("Australia","Sydney",1668,895));
                    _listAllCities.Add(new City("Australia","Melbourne",1640,917));
                    _listAllCities.Add(new City("Austria","Vienna",980,379));
                    _listAllCities.Add(new City("Belgium","Brussels",926,356));
                    _listAllCities.Add(new City("Brazil","São Paulo",664,826));
                    _listAllCities.Add(new City("Burkina Faso","Ouagadougou",890,611));
                    _listAllCities.Add(new City("Cambodia","Phnom Penh",1434,614));
                    _listAllCities.Add(new City("Cameroon","Yaoundé",962,659));
                    _listAllCities.Add(new City("Canada","Vancouver",271,363));
                    _listAllCities.Add(new City("Canada","Montreal",527,391));
                    _listAllCities.Add(new City("Chili","Santiago",538,890));
                    _listAllCities.Add(new City("China","Shanghai",1520,495));
                    _listAllCities.Add(new City("China","Beijing",1492,435));
                    _listAllCities.Add(new City("Colombia","Bogotá",525,659));
                    _listAllCities.Add(new City("Côte d'Ivoire","Abidjan",878,651));
                    _listAllCities.Add(new City("Croatia","Zagreb",986,394));
                    _listAllCities.Add(new City("Cuba","Havana",481,547));
                    _listAllCities.Add(new City("Denmark","Copenhagen",964,316));
                    _listAllCities.Add(new City("Egypt","Cairo",1058,501));
                    _listAllCities.Add(new City("Finland","Helsinki",1024,277));
                    _listAllCities.Add(new City("France","Paris",912,377));
                    _listAllCities.Add(new City("France","Lyon",924,400));
                    _listAllCities.Add(new City("Germany","Berlin",967,341));
                    _listAllCities.Add(new City("Greece","Athens",1021,447));
                    _listAllCities.Add(new City("Haiti","Port-au-Prince",532,574));
                    _listAllCities.Add(new City("Hungary","Budapest",999,383));
                    _listAllCities.Add(new City("Iceland","Reykjavík",792,243));
                    _listAllCities.Add(new City("India","New Delhi",1302,528));
                    _listAllCities.Add(new City("Indonesia","Jakarta",1447,724));
                    _listAllCities.Add(new City("Iraq","Baghdad",1127,485));
                    _listAllCities.Add(new City("Ireland","Dublin",869,338));
                    _listAllCities.Add(new City("Israel","Jerusalem",1079,493));
                    _listAllCities.Add(new City("Italy","Rome",966,421));
                    _listAllCities.Add(new City("Jamaica","Kingston",509,576));
                    _listAllCities.Add(new City("Japan","Tokyo",1614,464));
                    _listAllCities.Add(new City("Japan","Osaka",1591,471));
                    _listAllCities.Add(new City("North Korea","Pyongyang",1544,441));
                    _listAllCities.Add(new City("South Korea","Seoul",1550,458));
                    _listAllCities.Add(new City("Lebanon","Beirut",1083,477));
                    _listAllCities.Add(new City("Malaysia","Kuala Lumpur",1420,665));
                    _listAllCities.Add(new City("Mali","Bamako",861,605));
                    _listAllCities.Add(new City("Mexico","Mexico",397,567));
                    _listAllCities.Add(new City("Morocco","Casablanca",962,483));
                    _listAllCities.Add(new City("Nepal","Kathmandu",1334,515));
                    _listAllCities.Add(new City("Netherlands","Amsterdam",928,341));
                    _listAllCities.Add(new City("New Zealand","Auckland",1791,909));
                    _listAllCities.Add(new City("Norway","Oslo",955,281));
                    _listAllCities.Add(new City("Pakistan","Karachi",1244,533));
                    _listAllCities.Add(new City("Palestine","Gaza",1078,493));
                    _listAllCities.Add(new City("Portugal","Lisbon",857,444));
                    _listAllCities.Add(new City("Qatar","Doha",1164,533));
                    _listAllCities.Add(new City("Romania","Bucharest",1034,398));
                    _listAllCities.Add(new City("Russia","Moscow",1089,311));
                    _listAllCities.Add(new City("Rwanda","Kigali",1056,690));
                    _listAllCities.Add(new City("Saudi Arabia","Riyadh",1137,539));
                    _listAllCities.Add(new City("Senegal","Dakar",814,597));
                    _listAllCities.Add(new City("Singapore","Singapore",1434,678));
                    _listAllCities.Add(new City("South Africa","Johannesburg",1046,846));
                    _listAllCities.Add(new City("Spain","Madrid",884,435));
                    _listAllCities.Add(new City("Sweden","Stockholm",988,285));
                    _listAllCities.Add(new City("Switzerland","Zürich",944,384));
                    _listAllCities.Add(new City("Taiwan","Taipei",1519,536));
                    _listAllCities.Add(new City("Thailand","Bangkok",1415,601));
                    _listAllCities.Add(new City("Tunisia","Tunis",951,460));
                    _listAllCities.Add(new City("Turkey","Istanbul",1047,427));
                    _listAllCities.Add(new City("United Arab Emirates","Dubai",1184,533));
                    _listAllCities.Add(new City("United Kingdom","London",900,351));
                    _listAllCities.Add(new City("USA","New York",523,428));
                    _listAllCities.Add(new City("USA","Los Angeles",298,473));
                    _listAllCities.Add(new City("Vietnam","Ho Chi Minh",1446,623));
                    break;
                case StateManager.Language.FR :
                    _listAllCities.Add(new City("Afghanistan","Kabul",1262,456));
                    _listAllCities.Add(new City("Algerie","Algers",916,459));
                    _listAllCities.Add(new City("Argentine","Buenos Aires",601,899));
                    _listAllCities.Add(new City("Australie","Sydney",1668,895));
                    _listAllCities.Add(new City("Australie","Melbourne",1640,917));
                    _listAllCities.Add(new City("Autriche","Vienne",980,379));
                    _listAllCities.Add(new City("Belgique","Bruxelle",926,356));
                    _listAllCities.Add(new City("Brésil","São Paulo",664,826));
                    _listAllCities.Add(new City("Burkina Faso","Ouagadougou",890,611));
                    _listAllCities.Add(new City("Cambodge","Phnom Penh",1434,614));
                    _listAllCities.Add(new City("Cameroon","Yaoundé",962,659));
                    _listAllCities.Add(new City("Canada","Vancouver",271,363));
                    _listAllCities.Add(new City("Canada","Montreal",527,391));
                    _listAllCities.Add(new City("Chili","Santiago",538,890));
                    _listAllCities.Add(new City("Chine","Shanghai",1520,495));
                    _listAllCities.Add(new City("Chine","Beijing",1492,435));
                    _listAllCities.Add(new City("Colombie","Bogotá",525,659));
                    _listAllCities.Add(new City("Côte d'Ivoire","Abidjan",878,651));
                    _listAllCities.Add(new City("Croatie","Zagreb",986,394));
                    _listAllCities.Add(new City("Cuba","Havana",481,547));
                    _listAllCities.Add(new City("Danemark","Copenhagen",964,316));
                    _listAllCities.Add(new City("Egypte","Le Caire",1058,501));
                    _listAllCities.Add(new City("Finlande","Helsinki",1024,277));
                    _listAllCities.Add(new City("France","Paris",912,377));
                    _listAllCities.Add(new City("France","Lyon",924,400));
                    _listAllCities.Add(new City("Allemagne","Berlin",967,341));
                    _listAllCities.Add(new City("Grèce","Athenes",1021,447));
                    _listAllCities.Add(new City("Haiti","Port-au-Prince",532,574));
                    _listAllCities.Add(new City("Hongrie","Budapest",999,383));
                    _listAllCities.Add(new City("Islande","Reykjavík",792,243));
                    _listAllCities.Add(new City("Inde","New Delhi",1302,528));
                    _listAllCities.Add(new City("Indonesie","Jakarta",1447,724));
                    _listAllCities.Add(new City("Iraq","Baghdad",1127,485));
                    _listAllCities.Add(new City("Irlande","Dublin",869,338));
                    _listAllCities.Add(new City("Israel","Jerusalem",1079,493));
                    _listAllCities.Add(new City("Italie","Rome",966,421));
                    _listAllCities.Add(new City("Jamaique","Kingston",509,576));
                    _listAllCities.Add(new City("Japon","Tokyo",1614,464));
                    _listAllCities.Add(new City("Japon","Osaka",1591,471));
                    _listAllCities.Add(new City("Corée du Nord","Pyongyang",1544,441));
                    _listAllCities.Add(new City("Corée du Sud","Seoul",1550,458));
                    _listAllCities.Add(new City("Liban","Beirut",1083,477));
                    _listAllCities.Add(new City("Malaisie","Kuala Lumpur",1420,665));
                    _listAllCities.Add(new City("Mali","Bamako",861,605));
                    _listAllCities.Add(new City("Mexique","Mexico",397,567));
                    _listAllCities.Add(new City("Maroc","Casablanca",962,483));
                    _listAllCities.Add(new City("Nepal","Kathmandu",1334,515));
                    _listAllCities.Add(new City("Pays-Bas","Amsterdam",928,341));
                    _listAllCities.Add(new City("Nouvelle Zélande","Auckland",1791,909));
                    _listAllCities.Add(new City("Norvège","Oslo",955,281));
                    _listAllCities.Add(new City("Pakistan","Karachi",1244,533));
                    _listAllCities.Add(new City("Palestine","Gaza",1078,493));
                    _listAllCities.Add(new City("Portugal","Lisbone",857,444));
                    _listAllCities.Add(new City("Qatar","Doha",1164,533));
                    _listAllCities.Add(new City("Romanie","Bucharest",1034,398));
                    _listAllCities.Add(new City("Russie","Moscou",1089,311));
                    _listAllCities.Add(new City("Rwanda","Kigali",1056,690));
                    _listAllCities.Add(new City("Arabie Saoudite","Riyadh",1137,539));
                    _listAllCities.Add(new City("Senegal","Dakar",814,597));
                    _listAllCities.Add(new City("Singapour","Singapore",1434,678));
                    _listAllCities.Add(new City("Afrique du Sud","Johannesburg",1046,846));
                    _listAllCities.Add(new City("Espagne","Madrid",884,435));
                    _listAllCities.Add(new City("Suède","Stockholm",988,285));
                    _listAllCities.Add(new City("Suisse","Zürich",944,384));
                    _listAllCities.Add(new City("Taiwan","Taipei",1519,536));
                    _listAllCities.Add(new City("Thailande","Bangkok",1415,601));
                    _listAllCities.Add(new City("Tunisie","Tunis",951,460));
                    _listAllCities.Add(new City("Turquie","Istanbul",1047,427));
                    _listAllCities.Add(new City("Emirats Arabe Unis","Dubai",1184,533));
                    _listAllCities.Add(new City("Grande Bretagne","Londres",900,351));
                    _listAllCities.Add(new City("USA","New York",523,428));
                    _listAllCities.Add(new City("USA","Los Angeles",298,473));
                    _listAllCities.Add(new City("Vietnam","Ho Chi Minh",1446,623));
                    break;
                case StateManager.Language.CN :
                    break;
            }


        }
    }
}