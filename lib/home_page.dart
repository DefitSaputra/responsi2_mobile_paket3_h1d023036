import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'book_form_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Stream untuk update otomatis tanpa refresh
  final _booksStream = Supabase.instance.client
      .from('books')
      .stream(primaryKey: ['id']).order('id', ascending: false);

  Future<void> _deleteBook(int id) async {
    try {
      await Supabase.instance.client.from('books').delete().eq('id', id);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buku dihapus dari Deef Books")));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deef Books - Katalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _booksStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final books = snapshot.data!;
          if (books.isEmpty) return const Center(child: Text("Inventaris Kosong"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3E2723))),
                                Text('${book['penulis']} (${book['penerbit']})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(book['harga']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037), fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Stok: ${book['jumlah']} | Vol: ${book['volume']}', style: const TextStyle(fontSize: 12)),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookFormPage(bookData: book)))),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBook(book['id'])),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Buku", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookFormPage())),
      ),
    );
  }
}