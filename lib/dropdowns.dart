import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

List<String> _nationalities = [
  '',
  'Afghan',
  'Albanian',
  'Algerian',
  'American',
  'Andorran',
  'Angolan',
  'Antiguans',
  'Argentinean',
  'Armenian',
  'Australian',
  'Austrian',
  'Azerbaijani',
  'Bahamian',
  'Bahraini',
  'Bangladeshi',
  'Barbadian',
  'Barbudans',
  'Batswana',
  'Belarusian',
  'Belgian',
  'Belizean',
  'Beninese',
  'Bhutanese',
  'Bolivian',
  'Bosnian',
  'Brazilian',
  'British',
  'Bruneian',
  'Bulgarian',
  'Burkinabe',
  'Burmese',
  'Burundian',
  'Cambodian',
  'Cameroonian',
  'Canadian',
  'Cape Verdean',
  'Central African',
  'Chadian',
  'Chilean',
  'Chinese',
  'Colombian',
  'Comoran',
  'Congolese',
  'Costa Rican',
  'Croatian',
  'Cuban',
  'Cypriot',
  'Czech',
  'Danish',
  'Djibouti',
  'Dominican',
  'Dutch',
  'East Timorese',
  'Ecuadorean',
  'Egyptian',
  'Emirian',
  'Equatorial Guinean',
  'Eritrean',
  'Estonian',
  'Ethiopian',
  'Fijian',
  'Filipino',
  'Finnish',
  'French',
  'Gabonese',
  'Gambian',
  'Georgian',
  'German',
  'Ghanaian',
  'Greek',
  'Grenadian',
  'Guatemalan',
  'Guinea-Bissauan',
  'Guinean',
  'Guyanese',
  'Haitian',
  'Herzegovinian',
  'Honduran',
  'Hungarian',
  'Icelander',
  'Indian',
  'Indonesian',
  'Iranian',
  'Iraqi',
  'Irish',
  'Israeli',
  'Italian',
  'Ivorian',
  'Jamaican',
  'Japanese',
  'Jordanian',
  'Kazakhstani',
  'Kenyan',
  'Kittian and Nevisian',
  'Kuwaiti',
  'Kyrgyz',
  'Laotian',
  'Latvian',
  'Lebanese',
  'Liberian',
  'Libyan',
  'Liechtensteiner',
  'Lithuanian',
  'Luxembourger',
  'Macedonian',
  'Madagascan',
  'Malagasy',
  'Malawian',
  'Malaysian',
  'Maldivan',
  'Malian',
  'Maltese',
  'Marshallese',
  'Mauritanian',
  'Mauritian',
  'Mexican',
  'Micronesian',
  'Moldovan',
  'Monacan',
  'Mongolian',
  'Moroccan',
  'Mosotho',
  'Motswana',
  'Mozambican',
  'Namibian',
  'Nauruan',
  'Nepalese',
  'New Zealander',
  'Ni-Vanuatu',
  'Nicaraguan',
  'Nigerian',
  'North Korean',
  'Northern Irish',
  'Norwegian',
  'Omani',
  'Pakistani',
  'Palauan',
  'Panamanian',
  'Papua New Guinean',
  'Paraguayan',
  'Peruvian',
  'Polish',
  'Portuguese',
  'Qatari',
  'Romanian',
  'Russian',
  'Rwandan',
  'Saint Lucian',
  'Salvadoran',
  'Samoan',
  'San Marinese',
  'Sao Tomean',
  'Saudi',
  'Scottish',
  'Senegalese',
  'Serbian',
  'Seychellois',
  'Sierra Leonean',
  'Singaporean',
  'Slovakian',
  'Slovenian',
  'Solomon Islander',
  'Somali',
  'South African',
  'South Korean',
  'Spanish',
  'Sri Lankan',
  'Sudanese',
  'Surinamer',
  'Swazi',
  'Swedish',
  'Swiss',
  'Syrian',
  'Taiwanese',
  'Tajik',
  'Tanzanian',
  'Thai',
  'Togolese',
  'Tongan',
  'Trinidadian or Tobagonian',
  'Tunisian',
  'Turkish',
  'Tuvaluan',
  'Ugandan',
  'Ukrainian',
  'Uruguayan',
  'Uzbekistani',
  'Venezuelan',
  'Vietnamese',
  'Welsh',
  'Yemenite',
  'Zambian',
  'Zimbabwean'
];

List<DropdownMenuItem<String>> getDropDownMenuNationalities() {
  List<DropdownMenuItem<String>> allnationalities = [];
  for (String nationalitieslist in _nationalities) {
    allnationalities.add(DropdownMenuItem(
        value: nationalitieslist, child: Text(nationalitieslist)));
  }
  return allnationalities;
}

List<String> relationship = [
  '',
  'Mother',
  'Brother',
  'Sister',
  'Nephew',
  'Niece',
  'Cousin',
  'Husband',
  'Wife',
  'Son',
  'Daughter',
  'Uncle',
  'Aunt',
  'Other',
];
List<DropdownMenuItem<String>> getDropDownMenuRelationship() {
  List<DropdownMenuItem<String>> allrelationship = [];
  for (String relationshiplist in relationship) {
    allrelationship.add(DropdownMenuItem(
        value: relationshiplist, child: Text(relationshiplist)));
  }
  return allrelationship;
}

List<String> marriagestatus = ['', 'Single', 'Married', 'Divorced'];

List<DropdownMenuItem<String>> getDropDownMenuMarriageStatus() {
  List<DropdownMenuItem<String>> allmarriagestatus = [];
  for (String marriagestatuslist in marriagestatus) {
    allmarriagestatus.add(DropdownMenuItem(
        value: marriagestatuslist, child: Text(marriagestatuslist)));
  }
  return allmarriagestatus;
}

List<String> gender = ['', 'Male', 'Female'];
List<DropdownMenuItem<String>> getDropDownMenuGender() {
  List<DropdownMenuItem<String>> allgender = [];
  for (String genderlist in gender) {
    allgender.add(DropdownMenuItem(value: genderlist, child: Text(genderlist)));
  }
  return allgender;
}

List<String> shippingstatus = ['', 'shipped', 'unshipped'];
List<DropdownMenuItem<String>> getDropDownMenuSippingStatus() {
  List<DropdownMenuItem<String>> allstatuses = [];
  for (String statuslist in shippingstatus) {
    String? capitalized = toBeginningOfSentenceCase(statuslist);
    allstatuses
        .add(DropdownMenuItem(value: statuslist, child: Text(capitalized!)));
  }
  return allstatuses;
}
