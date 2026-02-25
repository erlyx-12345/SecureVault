import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

/// Minimal `ProfileView` placeholder.
class ProfileView extends StatelessWidget {
	const ProfileView({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		final vm = Provider.of<ProfileViewModel>(context);
		return Scaffold(
			appBar: AppBar(title: const Text('Profile')),
			body: Center(child: Text('Hello, ${vm.name}')),
		);
	}
}
