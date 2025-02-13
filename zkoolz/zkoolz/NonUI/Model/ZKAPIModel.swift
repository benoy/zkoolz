//
//  ZKAPIModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 18/06/24.
//

import Foundation

struct ZKDictionaryWord: Codable {
    
    let word: String
    let meanings: [ZKDictionaryMeaning]
}

struct ZKDictionaryMeaning: Codable {
    let partOfSpeech: String
    let definitions: [ZKDefinition]
}

struct ZKDefinition: Codable {
    let definition: String
    let example: String?
}


/*
 [
   {
     "word": "hug",
     "phonetic": "/hʌɡ/",
     "phonetics": [
       {
         "text": "/hʌɡ/",
         "audio": "https://api.dictionaryapi.dev/media/pronunciations/en/hug-us.mp3",
         "sourceUrl": "https://commons.wikimedia.org/w/index.php?curid=614786",
         "license": {
           "name": "BY-SA 3.0",
           "url": "https://creativecommons.org/licenses/by-sa/3.0"
         }
       }
     ],
     "meanings": [
       {
         "partOfSpeech": "noun",
         "definitions": [
           {
             "definition": "A close embrace, especially when charged with such an emotion as represented by: affection, joy, relief, lust, anger, agression, compassion, and the like, as opposed to being characterized by formality, equivocation or ambivalence (a half-embrace or \"little hug\").",
             "synonyms": [],
             "antonyms": []
           },
           {
             "definition": "A particular grip in wrestling.",
             "synonyms": [],
             "antonyms": []
           }
         ],
         "synonyms": [],
         "antonyms": []
       },
       {
         "partOfSpeech": "verb",
         "definitions": [
           {
             "definition": "To crouch; huddle as with cold.",
             "synonyms": [],
             "antonyms": []
           },
           {
             "definition": "To cling closely together.",
             "synonyms": [],
             "antonyms": []
           },
           {
             "definition": "To embrace by holding closely, especially in the arms.",
             "synonyms": [],
             "antonyms": [],
             "example": "Billy hugged Danny until he felt better."
           },
           {
             "definition": "To stay close to (the shore etc.)",
             "synonyms": [],
             "antonyms": []
           },
           {
             "definition": "To hold fast; to cling to; to cherish.",
             "synonyms": [],
             "antonyms": []
           }
         ],
         "synonyms": [
           "cleave",
           "stick",
           "hunker",
           "squat",
           "stoop",
           "accoll",
           "coll",
           "embrace",
           "treasure"
         ],
         "antonyms": []
       }
     ],
     "license": {
       "name": "CC BY-SA 3.0",
       "url": "https://creativecommons.org/licenses/by-sa/3.0"
     },
     "sourceUrls": [
       "https://en.wiktionary.org/wiki/hug"
     ]
   }
 ]
 */
