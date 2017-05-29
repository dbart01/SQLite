//
//  extensions.m
//  SQLite
//
//  Created by Dima Bart on 2017-05-20.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

#import <SQLite/extensions.h>

#pragma mark - SQLite -

//SQLite3 _Nullable sqliteCreate(SQLite3String _Nonnull path) {
//    SQLite3 sqlite = NULL;
//    int result = sqlite3_open(path, &sqlite);
//    if (result == SQLITE_OK) {
//        return sqlite;
//    } else {
//        return NULL;
//    }
//}

//SQLite3Statement _Nullable sqlitePrepare(SQLite3 _Nonnull sqlite, SQLite3String _Nonnull sql) {
//    SQLite3Statement statement = NULL;
//    int result = sqlite3_prepare_v2(sqlite, sql, -1, &statement, NULL);
//    if (result == SQLITE_OK) {
//        return statement;
//    } else {
//        return NULL;
//    }
//}

#pragma mark - Statement -

//SQLite3String escape(SQLite3String query) {
//    char *escapedString = sqlite3_mprintf("%q", query);
//    sqlite3_free(escapedString);
//    return escapedString;
//}
