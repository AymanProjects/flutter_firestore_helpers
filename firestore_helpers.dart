import 'package:cloud_firestore/cloud_firestore.dart';

/// The base database service class that you can instiantiate or extend
/// ```dart
/// DatabaseService<Note> noteDBs = DatabaseService<Note>("notes",fromDS: (id,data) => Note.fromDS(id,data), toMap: (note)=>note.toMap());
/// ```
///
class Collection<T> {
  /// path of the collection to use as base path for all the operations
  String collection;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///
  /// Function to convert the firestore [DocumentSnapshot] into the model class [T]
  /// provides [id] and [Map<String,dynamic> data] and must return [T] object.
  ///
  final T Function(String id, Map<String, dynamic> json) fromJson;

  ///
  ///Function to convert object [T] to [Map<String,dynamic>], receives instance of [T],
  ///and should always return [Map<String,dynamic>]
  ///
  final Map<String, dynamic> Function(T model) toJson;

  /// Create instance of Database service
  /// [collection] path is required
  /// [fromJson] is required to get document snapshot as object [T]
  ///
  Collection(this.collection, {this.fromJson, this.toJson});

  /// Returns instance of FirebaseFirestore
  FirebaseFirestore get db => _db;

  /// Get a single document of [id] from the [collection]
  /// Returns null if the document does not exist
  Future<T> getSingle(String id) async {
    var snap = await _db.collection(collection).doc(id).get();
    if (!snap.exists) return null;
    return fromJson(snap.id, snap.data());
  }

  /// Returns a single document of [id] from [collection]
  /// as stream so that updates can be listened
  Stream<T> getSingleAsStream(String id) {
    return _db
        .collection(collection)
        .doc(id)
        .snapshots()
        .map((snap) => snap.exists ? fromJson(snap.id, snap.data()) : null);
  }

  /// Returns list of all the documents from [collection]
  /// as a stream so that changes can be listened
  Stream<List<T>> getAllAsStream() {
    var ref = _db.collection(collection);
    return ref.snapshots().map((list) =>
        list.docs.map((doc) => fromJson(doc.id, doc.data())).toList());
  }

  /// Returns the list of documents from [collection], in the order provided in
  /// [orderBy] and matches the [args] supplied.
  /// use [startAfter], [startAt], [endAt], [endBefore] to perform cursor based queries
  /// and pagination of data
  Future<List<T>> where({
    List<OrderBy> orderBy,
    List<QueryArgs> args,
    int limit,
    dynamic startAfter,
    dynamic startAt,
    dynamic endAt,
    dynamic endBefore,
  }) async {
    CollectionReference collref = _db.collection(collection);
    Query ref;
    if (args != null) {
      for (final arg in args) {
        if (arg is QueryArgs) {
          if (ref == null)
            ref = collref.where(
              arg.key,
              isEqualTo: arg.isEqualTo,
              isGreaterThan: arg.isGreaterThan,
              isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
              isLessThan: arg.isLessThan,
              isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
              isNull: arg.isNull,
              arrayContains: arg.arrayContains,
              arrayContainsAny: arg.arrayContainsAny,
              whereIn: arg.whereIn,
            );
          else
            ref = ref.where(
              arg.key,
              isEqualTo: arg.isEqualTo,
              isGreaterThan: arg.isGreaterThan,
              isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
              isLessThan: arg.isLessThan,
              isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
              isNull: arg.isNull,
              arrayContains: arg.arrayContains,
              arrayContainsAny: arg.arrayContainsAny,
              whereIn: arg.whereIn,
            );
          ;
        } else {
          if (ref == null)
            ref = collref.where(arg.key, isEqualTo: arg.value);
          else
            ref = ref.where(arg.key, isEqualTo: arg.value);
        }
      }
    }
    if (orderBy != null) {
      orderBy.forEach((order) {
        if (ref == null)
          ref = collref.orderBy(order.field, descending: order.descending);
        else
          ref = ref.orderBy(order.field, descending: order.descending);
      });
    }
    if (limit != null) {
      if (ref == null)
        ref = collref.limit(limit);
      else
        ref = ref.limit(limit);
    }
    if (startAfter != null && orderBy != null) {
      ref = ref.startAfter([startAfter]);
    }
    if (startAt != null && orderBy != null) {
      ref = ref.startAt([startAt]);
    }
    if (endAt != null && orderBy != null) {
      ref = ref.endAt([endAt]);
    }
    if (endBefore != null && orderBy != null) {
      ref = ref.endBefore([endBefore]);
    }
    QuerySnapshot query;
    if (ref != null)
      query = await ref.get();
    else
      query = await collref.get();

    return query.docs.map((doc) => fromJson(doc.id, doc.data())).toList();
  }

  /// Returns the list of documents from [collection], in the order provided in
  /// [orderBy] and matches the [args] supplied as a stream so that changes can be
  /// listened.
  /// Use [startAfter], [startAt], [endAt], [endBefore] to perform cursor based
  /// queries and pagination of data
  Stream<List<T>> whereAsStream({
    List<OrderBy> orderBy,
    List<QueryArgs> args,
    int limit,
    dynamic startAfter,
    dynamic startAt,
    dynamic endBefore,
    dynamic endAt,
  }) {
    CollectionReference collref = _db.collection(collection);
    Query ref;
    if (orderBy != null) {
      orderBy.forEach((order) {
        if (ref == null)
          ref = collref.orderBy(order.field, descending: order.descending);
        else
          ref = ref.orderBy(order.field, descending: order.descending);
      });
    }
    if (args != null) {
      for (final arg in args) {
        if (arg is QueryArgs) {
          if (ref == null)
            ref = collref.where(
              arg.key,
              isEqualTo: arg.isEqualTo,
              isGreaterThan: arg.isGreaterThan,
              isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
              isLessThan: arg.isLessThan,
              isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
              isNull: arg.isNull,
              arrayContains: arg.arrayContains,
              arrayContainsAny: arg.arrayContainsAny,
              whereIn: arg.whereIn,
            );
          else
            ref = ref.where(
              arg.key,
              isEqualTo: arg.isEqualTo,
              isGreaterThan: arg.isGreaterThan,
              isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
              isLessThan: arg.isLessThan,
              isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
              isNull: arg.isNull,
              arrayContains: arg.arrayContains,
              arrayContainsAny: arg.arrayContainsAny,
              whereIn: arg.whereIn,
            );
        } else {
          if (ref == null)
            ref = collref.where(arg.key, isEqualTo: arg.value);
          else
            ref = ref.where(arg.key, isEqualTo: arg.value);
        }
      }
    }
    if (limit != null) {
      if (ref == null)
        ref = collref.limit(limit);
      else
        ref = ref.limit(limit);
    }
    if (startAfter != null && orderBy != null) {
      ref = ref.startAfter([startAfter]);
    }
    if (startAt != null && orderBy != null) {
      ref = ref.startAt([startAt]);
    }
    if (endAt != null && orderBy != null) {
      ref = ref.endAt([endAt]);
    }
    if (endBefore != null && orderBy != null) {
      ref = ref.endBefore([endBefore]);
    }
    if (ref != null)
      return ref.snapshots().map((snap) =>
          snap.docs.map((doc) => fromJson(doc.id, doc.data())).toList());
    else
      return collref.snapshots().map((snap) =>
          snap.docs.map((doc) => fromJson(doc.id, doc.data())).toList());
  }

  /// Returns the list of documents from [from] date to [to] date matched by [orderBy]
  /// is ordered by the [orderBy] provided.
  /// additional [args] can be supplied to perform specific query.
  Future<List<T>> getAllByDate(String orderBy, DateTime from, DateTime to,
      {List<QueryArgs> args = const []}) async {
    var ref = _db.collection(collection).orderBy(orderBy);
    for (final arg in args) {
      if (arg is QueryArgs) {
        ref = ref.where(
          arg.key,
          isEqualTo: arg.isEqualTo,
          isGreaterThan: arg.isGreaterThan,
          isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
          isLessThan: arg.isLessThan,
          isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
          isNull: arg.isNull,
          arrayContains: arg.arrayContains,
          arrayContainsAny: arg.arrayContainsAny,
          whereIn: arg.whereIn,
        );
      } else {
        ref = ref.where(arg.key, isEqualTo: arg.value);
      }
    }
    QuerySnapshot query = await ref.startAt([from]).endAt([to]).get();
    return query.docs.map((doc) => fromJson(doc.id, doc.data())).toList();
  }

  /// Returns the list of documents from [from] date to [to] date matched by [field] from [collection]
  /// as a stream so that changes can be listened and is ordered by the [field] provided.
  /// additional [args] can be supplied to perform specific query.
  Stream<List<T>> getAllByDateAsStream(String field, DateTime from, DateTime to,
      {List<QueryArgs> args = const []}) {
    var ref = _db.collection(collection).orderBy(field, descending: true);
    for (final arg in args) {
      if (arg is QueryArgs) {
        ref = ref.where(
          arg.key,
          isEqualTo: arg.isEqualTo,
          isGreaterThan: arg.isGreaterThan,
          isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
          isLessThan: arg.isLessThan,
          isLessThanOrEqualTo: arg.isLessThanOrEqualTo,
          isNull: arg.isNull,
          arrayContains: arg.arrayContains,
          arrayContainsAny: arg.arrayContainsAny,
          whereIn: arg.whereIn,
        );
      } else {
        ref = ref.where(arg.key, isEqualTo: arg.value);
      }
    }
    var query = ref.startAfter([to]).endAt([from]).snapshots();
    return query.map((snap) =>
        snap.docs.map((doc) => fromJson(doc.id, doc.data())).toList());
  }

  /// Creates new document based on the provided [data] and [id]  in the [collection]
  /// If [id] is null, [id] will be auto generated by firestore
  ///
  Future<dynamic> create(Map<String, dynamic> data, {String id}) {
    if (id != null) {
      return _db.collection(collection).doc(id).set(data);
    } else {
      return _db.collection(collection).add(data);
    }
  }

  ///
  /// Updates the document with [id] with the provided [data] to the [collection]
  ///
  Future<void> update(String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).update(data);
  }

  /// Removes item with [id] from [collection]
  Future<void> remove(String id) {
    return _db.collection(collection).doc(id).delete();
  }
}

/// Supply query to query the collection based on [key] field and the
/// values supplied to various arguments
/// Please refer to firestore documentation for understanding
/// various operators of the query
class QueryArgs {
  /// Field to match
  final dynamic key;
  final dynamic value;

  /// performs equality == check
  final dynamic isEqualTo;

  /// performs less than < check
  final dynamic isLessThan;

  /// performs less than or equal to <= check
  final dynamic isLessThanOrEqualTo;

  /// performs greater than or equal to >= check
  final dynamic isGreaterThanOrEqualTo;

  /// performs greater than > check
  final dynamic isGreaterThan;

  /// performs array contains check
  final dynamic arrayContains;

  /// performs array contains any check
  final List<dynamic> arrayContainsAny;

  /// performs where in check
  final List<dynamic> whereIn;

  /// performs if is null check
  final bool isNull;

  /// Create instance of QueryArgs
  QueryArgs(
    this.key, {
    this.value,
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.isNull,
    this.isGreaterThanOrEqualTo,
  });
}

/// Provide ordering option to queries
class OrderBy {
  /// Field to order by
  final String field;

  /// Whether the order should be descending, default is false
  final bool descending;

  /// Creates instance of OrderBy
  OrderBy(this.field, {this.descending = false});
}
