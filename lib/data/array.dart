import 'package:flutter/material.dart';
import '../model/category.dart';

class Array {

  static List<Category> headerCategories = [
    Category(-1, "All Places", Icons.dashboard),
    Category(-2, "Favorites", Icons.favorite),
    Category(-3, "News Info", Icons.subject),
  ];

  static List<Category> categories = [
    Category(11, "Featured Places", Icons.mood),
    Category(1, "Tourist Destination", Icons.card_travel),
    Category(2, "Food & Drink", Icons.local_dining),
    Category(3, "Hotels", Icons.hotel),
    Category(4, "Entertainment", Icons.theaters),
    Category(5, "Sport", Icons.directions_bike),

    Category(6, "Shopping", Icons.shopping_basket),
    Category(7, "Transportation", Icons.directions_bus),
    Category(8, "Religion", Icons.location_city),
    Category(9, "Public Services", Icons.account_balance),
    Category(10, "Money", Icons.credit_card),
  ];

}