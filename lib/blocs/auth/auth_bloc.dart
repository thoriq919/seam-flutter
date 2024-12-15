import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seam_flutter/models/user.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc() : super(AuthInitial()) {
    _authStateSubscription =
        _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          final docSnapshot =
              await _firestore.collection('users').doc(user.uid).get();

          if (docSnapshot.exists) {
            final userData = docSnapshot.data() ?? {};
            final userModel = UserModel.fromMap({
              ...userData,
              'uid': user.uid,
              'email': user.email,
            });
            add(AuthStateChanged(userModel));
          } else {
            add(const AuthStateChanged(null));
          }
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      } else {
        add(const AuthStateChanged(null));
      }
    });

    on<AuthStateChanged>((event, emit) async {
      if (event.user != null) {
        emit(Authenticated(event.user!));
      } else {
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final docSnapshot = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (docSnapshot.exists) {
          final userData = docSnapshot.data() ?? {};
          final userModel = UserModel.fromMap({
            ...userData,
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
          });
          emit(Authenticated(userModel));
        } else {
          emit(const AuthError('User data not found'));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'An error occurred'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'email': event.email,
          'createdAt': FieldValue.serverTimestamp(),
          'nama': event.nama,
          'alamat': event.alamat,
          'telp': event.telp,
          'foto': event.foto,
          'role': 'pegawai',
        });
        final docSnapshot = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (docSnapshot.exists) {
          final userData = docSnapshot.data() ?? {};
          final userModel = UserModel.fromMap({
            ...userData,
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
          });
          emit(Authenticated(userModel));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'An error occurred'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signOut();
        emit(Unauthenticated());
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? 'An error occurred'));
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
