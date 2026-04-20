import 'package:flutter/material.dart';
import '../services/investment_service.dart';

class NewOperationPage extends StatefulWidget {
  const NewOperationPage({super.key});

  @override
  State<NewOperationPage> createState() => _NewOperationPageState();
}

class _NewOperationPageState extends State<NewOperationPage> {
  final service = InvestmentService();

  String type = 'buy';
  bool loading = false;

  final assetController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  DateTime date = DateTime.now();

  Future<void> _save() async {
    final asset = assetController.text.trim();
    final quantity = double.tryParse(quantityController.text);
    final price = double.tryParse(priceController.text);

    if (asset.isEmpty || quantity == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha tudo corretamente')),
      );
      return;
    }

    setState(() => loading = true);

    await service.addOperation(
      type: type,
      asset: asset,
      quantity: quantity,
      price: price,
      date: date,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operação salva')),
    );

    Navigator.pop(context);
  }

  Widget _typeButton(String value, String label) {
    final selected = type == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => type = value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? Colors.green : Colors.white10,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
      ),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('Nova Operação'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _typeButton('buy', 'Compra'),
                const SizedBox(width: 10),
                _typeButton('sell', 'Venda'),
                const SizedBox(width: 10),
                _typeButton('dividend', 'Dividendos'),
              ],
            ),
            const SizedBox(height: 20),
            _input('Código da ação (ex: PETR4)', assetController),
            _input('Quantidade', quantityController),
            _input('Preço', priceController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _save,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Salvar operação'),
            )
          ],
        ),
      ),
    );
  }
}
