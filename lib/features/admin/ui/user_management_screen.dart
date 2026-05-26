import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/staggered_list_animator.dart';
import '../logic/admin_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('Tidak ada data user.'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchUsers,
            child: StaggeredListAnimator(
              padding: const EdgeInsets.all(20),
              itemCount: provider.users.length,
              horizontalOffset: -50.0,
              verticalOffset: 0.0,
              duration: const Duration(milliseconds: 350),
              itemBuilder: (context, index) {
                final user = provider.users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
                        child: Icon(
                          _getRoleIcon(user.role),
                           color: _getRoleColor(user.role),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getRoleColor(user.role),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: user.id == context.read<AuthProvider>().user?.id
                          ? IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.editColor),
                              onPressed: () => _showUserForm(context, user: user),
                            )
                          : const Icon(Icons.info_outline, color: Colors.grey), // Just for view
                    ),
                  );
                },
            ),
          );
        },
      ),
    );
  }

  void _showUserForm(BuildContext context, {UserModel? user}) {
    final isEdit = user != null;
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: user?.phone);
    final addressController = TextEditingController(text: user?.address);
    String role = user?.role ?? 'patient';
    final formKey = GlobalKey<FormState>();


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isEdit ? 'Edit User' : 'Tambah User Baru', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController, 
                  decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController, 
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                if (!isEdit) ...[
                  TextFormField(
                    controller: passwordController, 
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), 
                    obscureText: true,
                    validator: (v) => v == null || v.length < 8 ? 'Password minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: phoneController, 
                  decoration: const InputDecoration(labelText: 'Nomor HP (Opsional)', border: OutlineInputBorder()),
                  validator: (v) => v != null && v.isNotEmpty && v.length < 9 ? 'Minimal 9 digit' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController, 
                  decoration: const InputDecoration(labelText: 'Alamat (Opsional)', border: OutlineInputBorder()), 
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: ['patient', 'doctor'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (v) => role = v!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  final provider = context.read<AdminProvider>();
                  final data = {
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': role,
                    'phone': phoneController.text.trim(),
                    'address': addressController.text.trim(),
                  };
                  if (!isEdit) data['password'] = passwordController.text;

                  if (isEdit) {
                    await provider.updateUser(user.id, data);
                  } else {
                    await provider.createUser(data);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEdit ? 'UPDATE' : 'SIMPAN'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'doctor': return AppTheme.primaryColor;
      case 'patient': return AppTheme.accentColor;
      default: return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin': return Icons.admin_panel_settings;
      case 'doctor': return Icons.medical_services;
      case 'patient': return Icons.person;
      default: return Icons.help_outline;
    }
  }
}
