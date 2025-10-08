import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  });
  
  Future<void> signOut();
  
  User? get currentUser;
  
  Stream<User?> get authStateChanges;
}