//
//  YYGDataRelease.m
//  Ledger
//
//  Created by Ян on 22/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDataRelease.h"
#import "YGSQLite.h"
#import "YGTools.h"

void addReleaseAccounts(){
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSArray *entities = nil;
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        entities = @[
                     @[
                         @1, // account
                         @"Кошелёк",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @1, // attach
                         @100,
                         [NSNull null],
                         ],
                     @[
                         @1, // account
                         @"Карта",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @0, // attach
                         @101,
                         [NSNull null],
                         ],
                     @[
                         @1, // account
                         @"Заначка",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @0, // attach
                         @103,
                         [NSNull null],
                         ]
                     ];

    }
    else{
        entities = @[
                     @[
                         @1, // account
                         @"Pocket",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @1, // attach
                         @100,
                         [NSNull null],
                         ],
                     @[
                         @1, // account
                         @"Card",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @0, // attach
                         @101,
                         [NSNull null],
                         ],
                     @[
                         @1, // account
                         @"Stash",
                         [NSNull null],
                         @0,
                         @1, // rub
                         @1, // active
                         [YGTools stringFromDate:[NSDate date]],
                         [NSNull null],
                         @0, // attach
                         @103,
                         [NSNull null],
                         ]
                     ];
    }
    

    
    NSString *insertSQL = @"INSERT INTO entity (entity_type_id, name, sum, currency_id, active, active_from, active_to, attach, sort, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [sqlite fillTable:@"entity" items:entities updateSQL:insertSQL];
    
}


void addReleaseExpenseCategories(){
    
    NSArray *categories = nil;
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        
        categories = @[
                       @[
                           @2,
                           @"Продукты",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Чревоугодия",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @11,
                           @"Всякие излишества: алкоголь, курение и т.д.",
                           ],
                       @[
                           @2,
                           @"Хозяйство",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Коммуналка",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Ремонт/Мебель",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Одежда",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Здоровье",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2, // category_type_id
                           @"Красота", // name
                           @1, // active
                           [YGTools stringFromDate:[NSDate date]], // active_from
                           [NSNull null], // active_to
                           @101, // sort
                           [NSNull null],  // symbol
                           @0, // attach
                           @17, // parent_id
                           [NSNull null], // comment
                           ],
                       @[
                           @2,
                           @"Транспорт",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Связь",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Образование",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Развлечения",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @107,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Домашние животные",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Спорт",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Рукоделия",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Отдых/путешествия",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Книги",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Кино/музыка",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],

                       @[
                           @2,
                           @"Фото",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Семья",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @108,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Деловое",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @109,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Компьютерное",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Канцелярия",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Банковские расходы",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Государство",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @110,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Налоги",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Штрафы",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Потери",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @111,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];

    }
    else{
        categories = @[
                       @[
                           @2,
                           @"Foodstuffs",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Gluttony",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @11,
                           @"Excess: alcohol, smoking, glutton...",
                           ],
                       @[
                           @2,
                           @"Household expenses",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Utility payments",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Renovation & furniture",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Clothes",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Health",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2, // category_type_id
                           @"Beauty", // name
                           @1, // active
                           [YGTools stringFromDate:[NSDate date]], // active_from
                           [NSNull null], // active_to
                           @101, // sort
                           [NSNull null],  // symbol
                           @0, // attach
                           @17, // parent_id
                           [NSNull null], // comment
                           ],
                       @[
                           @2,
                           @"Transport",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Communications",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Education",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Entertainment",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @107,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Pets",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Sport",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Hand made",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Rest & travel",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Literature",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Movies & music",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],

                       @[
                           @2,
                           @"Photo",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Family",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @108,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Business",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @109,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Computer expenses",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Office expenses",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Bank expenses",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"State",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @110,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Tax",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Penalty",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           ],
                       @[
                           @2,
                           @"Loss",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @111,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];
        
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    [sqlite fillTable:@"category" items:categories updateSQL:insertSQL];
    
}


void addReleaseIncomeSources(){
    
    NSArray *сategories = nil;
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        
        сategories = @[
                       @[
                           @3,
                           @"Зарплата",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Разовый доход",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Подарки",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Продажа имущества",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Возврат",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Находка",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Наследство",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];
    }
    else{
        
        сategories = @[
                       @[
                           @3,
                           @"Salary",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Ad hoc income",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Gift",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Sale of property",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Return",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Godsend",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       @[
                           @3,
                           @"Inheritance",
                           @1,
                           [YGTools stringFromDate:[NSDate date]],
                           [NSNull null],
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           ],
                       ];
        
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, symbol, attach, parent_id, comment) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    [sqlite fillTable:@"category" items:сategories updateSQL:insertSQL];
}

