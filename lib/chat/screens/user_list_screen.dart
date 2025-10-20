import 'package:chatapp/chat/widgets/user_list_tile.dart';
import 'package:chatapp/chat/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered users provider
final filteredUsersProvider = Provider((ref) {
  final usersAsync = ref.watch(usersProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return usersAsync.whenData((users) {
    if (searchQuery.isEmpty) return users;
    
    return users.where((user) {
      final nameLower = user.name.toLowerCase();
      final emailLower = user.email.toLowerCase();
      return nameLower.contains(searchQuery) || emailLower.contains(searchQuery);
    }).toList();
  });
});

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  Future<void> onRefresh() async {
    ref.invalidate(usersProvider);
    ref.invalidate(requestsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoRefreshProvider);
    final users = ref.watch(filteredUsersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("All Users"),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: "Search user by name or email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: onRefresh,
        child: users.when(
          data: (userList) {
            if (userList.isEmpty && searchQuery.isNotEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No users found matching your search")),
                ],
              );
            }

            if (userList.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No other users found")),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return UserListTile(user: user);
              },
            );
          },
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(
                child: Column(
                  children: [
                    Text("Error: $error"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(usersProvider);
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}