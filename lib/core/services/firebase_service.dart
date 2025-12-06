import 'dart:async';

import '../../data/models/category_model.dart';
import '../../data/models/word_model.dart';

/// Local-only data layer that mimics a remote Firebase service.
class FirebaseService {
  FirebaseService();

  final Map<String, List<WordModel>> _words = {
    'basics': [
      WordModel(
        id: 'basics_hello',
        english: 'hello',
        kyrgyz: 'Салам',
        transcription: 'sa-lam',
        example: 'Салам! Бүгүн кантип жатасың?',
      ),
      WordModel(
        id: 'basics_thanks',
        english: 'thank you',
        kyrgyz: 'Рахмат',
        transcription: 'rah-mat',
        example: 'Рахмат, мага жардам бергениң үчүн.',
      ),
      WordModel(
        id: 'basics_yes',
        english: 'yes',
        kyrgyz: 'Ооба',
        transcription: 'oo-ba',
        example: 'Ооба, мен түшүндүм.',
      ),
      WordModel(
        id: 'basics_no',
        english: 'no',
        kyrgyz: 'Жок',
        transcription: 'zhok',
        example: 'Жок, азыр убактым жок.',
      ),
      WordModel(
        id: 'basics_please',
        english: 'please',
        kyrgyz: 'Суранам',
        transcription: 'su-ra-nam',
        example: 'Суранам, эшикти жаап кой.',
      ),
      WordModel(
        id: 'basics_good_morning',
        english: 'good morning',
        kyrgyz: 'Кутман таң',
        transcription: 'kut-man-taan',
        example: 'Кутман таң! Күнүң узун болсун.',
      ),
    ],
    'food': [
      WordModel(
        id: 'food_bread',
        english: 'bread',
        kyrgyz: 'Нан',
        transcription: 'nan',
        example: 'Базардан жаңы нан сатып алдым.',
      ),
      WordModel(
        id: 'food_tea',
        english: 'tea',
        kyrgyz: 'Чай',
        transcription: 'chai',
        example: 'Кел, бирге чай ичели.',
      ),
      WordModel(
        id: 'food_soup',
        english: 'soup',
        kyrgyz: 'Шорпо',
        transcription: 'shor-po',
        example: 'Суук күнү ысык шорпо жакшы.',
      ),
      WordModel(
        id: 'food_meat',
        english: 'meat',
        kyrgyz: 'Эт',
        transcription: 'et',
        example: 'Этти жай отто кууруп жатам.',
      ),
      WordModel(
        id: 'food_apple',
        english: 'apple',
        kyrgyz: 'Алма',
        transcription: 'al-ma',
        example: 'Бул алма абдан ширелүү экен.',
      ),
      WordModel(
        id: 'food_water',
        english: 'water',
        kyrgyz: 'Суу',
        transcription: 'suu',
        example: 'Күндү суу менен баштоону унутпа.',
      ),
    ],
    'family': [
      WordModel(
        id: 'family_mother',
        english: 'mother',
        kyrgyz: 'Апам',
        transcription: 'a-pam',
        example: 'Апам даамдуу тамак жасайт.',
      ),
      WordModel(
        id: 'family_father',
        english: 'father',
        kyrgyz: 'Атам',
        transcription: 'a-tam',
        example: 'Атам менен тоого бардым.',
      ),
      WordModel(
        id: 'family_brother',
        english: 'elder brother',
        kyrgyz: 'Агам',
        transcription: 'a-gam',
        example: 'Агам мага китеп белек кылды.',
      ),
      WordModel(
        id: 'family_sister',
        english: 'sister',
        kyrgyz: 'Карындашым',
        transcription: 'kar-yn-dashym',
        example: 'Карындашым мектепте окуйт.',
      ),
      WordModel(
        id: 'family_child',
        english: 'child',
        kyrgyz: 'Бала',
        transcription: 'ba-la',
        example: 'Бул бала оюнуна кубанып жатат.',
      ),
      WordModel(
        id: 'family_grandma',
        english: 'grandmother',
        kyrgyz: 'Чоң апа',
        transcription: 'chong-apa',
        example: 'Чоң апам жомокторду жакшы айтат.',
      ),
    ],
    'nature': [
      WordModel(
        id: 'nature_mountain',
        english: 'mountain',
        kyrgyz: 'Тоолор',
        transcription: 'too-lor',
        example: 'Тоолордо аба таза болот.',
      ),
      WordModel(
        id: 'nature_river',
        english: 'river',
        kyrgyz: 'Дарыя',
        transcription: 'da-rya',
        example: 'Дарыя жээгинде сейилдедик.',
      ),
      WordModel(
        id: 'nature_sun',
        english: 'sun',
        kyrgyz: 'Күн',
        transcription: 'kyn',
        example: 'Күн нуру жылуу сезилди.',
      ),
      WordModel(
        id: 'nature_snow',
        english: 'snow',
        kyrgyz: 'Кар',
        transcription: 'kar',
        example: 'Кар түндө көп жаады.',
      ),
      WordModel(
        id: 'nature_wind',
        english: 'wind',
        kyrgyz: 'Шамал',
        transcription: 'sha-mal',
        example: 'Шамал дарактардын жалбырагын кыймылдатты.',
      ),
      WordModel(
        id: 'nature_lake',
        english: 'lake',
        kyrgyz: 'Көл',
        transcription: 'kol',
        example: 'Ысык-Көл дүйнөгө белгилүү.',
      ),
    ],
    'animals': [
      WordModel(
        id: 'animals_horse',
        english: 'horse',
        kyrgyz: 'Ат',
        transcription: 'at',
        example: 'Кумайык ат чуркап жүрөт.',
      ),
      WordModel(
        id: 'animals_eagle',
        english: 'eagle',
        kyrgyz: 'Бүркүт',
        transcription: 'bur-kut',
        example: 'Бүркүт асманда айланып учту.',
      ),
      WordModel(
        id: 'animals_sheep',
        english: 'sheep',
        kyrgyz: 'Кой',
        transcription: 'koi',
        example: 'Койлор жайлоодо оттоп жүрөт.',
      ),
      WordModel(
        id: 'animals_dog',
        english: 'dog',
        kyrgyz: 'Ит',
        transcription: 'it',
        example: 'Ит үйдү кайтарып турат.',
      ),
      WordModel(
        id: 'animals_cat',
        english: 'cat',
        kyrgyz: 'Мышык',
        transcription: 'myshyk',
        example: 'Мышык күнгө жылынып жатат.',
      ),
      WordModel(
        id: 'animals_bird',
        english: 'bird',
        kyrgyz: 'Куш',
        transcription: 'kush',
        example: 'Куш эртең менен сайрайт.',
      ),
    ],
    'travel': [
      WordModel(
        id: 'travel_bus',
        english: 'bus',
        kyrgyz: 'Автобус',
        transcription: 'av-to-bus',
        example: 'Автобус шаардын борборуна кетти.',
      ),
      WordModel(
        id: 'travel_ticket',
        english: 'ticket',
        kyrgyz: 'Билет',
        transcription: 'bi-let',
        example: 'Билетти онлайн сатып алдым.',
      ),
      WordModel(
        id: 'travel_city',
        english: 'city',
        kyrgyz: 'Шаар',
        transcription: 'shaar',
        example: 'Бул шаарда көп музей бар.',
      ),
      WordModel(
        id: 'travel_road',
        english: 'road',
        kyrgyz: 'Жол',
        transcription: 'zhol',
        example: 'Бул жол тоого алып барат.',
      ),
      WordModel(
        id: 'travel_airport',
        english: 'airport',
        kyrgyz: 'Абамайдан',
        transcription: 'aba-mai-dan',
        example: 'Аэропортко эрте бар.',
      ),
      WordModel(
        id: 'travel_train',
        english: 'train',
        kyrgyz: 'Поезд',
        transcription: 'po-ezd',
        example: 'Поезд түштөн кийин келет.',
      ),
    ],
  };

  late final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'basics',
      title: 'Негизги сөздөр',
      description: 'Күнүмдүк сүйлөшүүгө керектүү учурашуу жана сылык сөздөр.',
      wordsCount: _words['basics']!.length,
    ),
    CategoryModel(
      id: 'food',
      title: 'Тамак-аш',
      description: 'Кафеде же базарда колдонулуучу азык-түлүк сөздөрү.',
      wordsCount: _words['food']!.length,
    ),
    CategoryModel(
      id: 'family',
      title: 'Үй-бүлө',
      description: 'Жакындар, туугандар жана алар тууралуу сөздөр.',
      wordsCount: _words['family']!.length,
    ),
    CategoryModel(
      id: 'nature',
      title: 'Табият',
      description: 'Тоолор, көлдөр жана аба ырайына байланышкан сөздөр.',
      wordsCount: _words['nature']!.length,
    ),
    CategoryModel(
      id: 'animals',
      title: 'Жаныбарлар',
      description: 'Күндөлүк турмушта кездешкен жаныбарлардын аталыштары.',
      wordsCount: _words['animals']!.length,
    ),
    CategoryModel(
      id: 'travel',
      title: 'Саякат',
      description: 'Жолго даярдык жана транспорт тууралуу сөздөр.',
      wordsCount: _words['travel']!.length,
    ),
  ];

  Future<List<CategoryModel>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _categories;
  }

  Future<List<WordModel>> fetchWordsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<WordModel>.of(_words[categoryId] ?? const []);
  }

  List<WordModel> getCachedWords(String categoryId) =>
      List<WordModel>.unmodifiable(_words[categoryId] ?? const []);

  List<WordModel> get allWords =>
      List<WordModel>.unmodifiable(_words.values.expand((value) => value));

  Future<void> saveUserProgress(String userId, Map<String, int> progress) async {
    await Future.delayed(const Duration(milliseconds: 120));
  }
}
