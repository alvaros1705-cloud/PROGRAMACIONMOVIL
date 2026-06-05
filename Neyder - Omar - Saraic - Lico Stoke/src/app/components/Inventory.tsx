import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "./ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Plus, Edit, Trash2, Package, AlertCircle } from "lucide-react";
import { Badge } from "./ui/badge";
import { useTheme } from "../context/ThemeContext";

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  cost: number;
  stock: number;
  minStock: number;
  barcode?: string;
}

const CATEGORIES = ["Vinos", "Cervezas", "Licores", "Whisky", "Ron", "Vodka", "Tequila", "Otros"];

interface InventoryProps {
  userId: string;
}

export function Inventory({ userId }: InventoryProps) {
  const { theme } = useTheme();
  const isDark = theme === "dark";
  const [products, setProducts] = useState<Product[]>([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");

  const [formData, setFormData] = useState({
    name: "",
    category: "Vinos",
    price: "",
    cost: "",
    stock: "",
    minStock: "10",
    barcode: ""
  });

  useEffect(() => {
    const stored = localStorage.getItem(`licostoke_${userId}_products`);
    if (stored) {
      setProducts(JSON.parse(stored));
    } else {
      const sampleProducts: Product[] = [
        { id: "1", name: "Vino Tinto Reserva", category: "Vinos", price: 15000, cost: 8000, stock: 24, minStock: 10 },
        { id: "2", name: "Cerveza Corona", category: "Cervezas", price: 2500, cost: 1500, stock: 120, minStock: 20 },
        { id: "3", name: "Whisky Jack Daniels", category: "Whisky", price: 85000, cost: 60000, stock: 8, minStock: 5 },
        { id: "4", name: "Ron Bacardi", category: "Ron", price: 35000, cost: 22000, stock: 15, minStock: 8 },
      ];
      setProducts(sampleProducts);
      localStorage.setItem(`licostoke_${userId}_products`, JSON.stringify(sampleProducts));
    }
  }, [userId]);

  const saveProducts = (newProducts: Product[]) => {
    setProducts(newProducts);
    localStorage.setItem(`licostoke_${userId}_products`, JSON.stringify(newProducts));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const product: Product = {
      id: editingProduct?.id || Date.now().toString(),
      name: formData.name,
      category: formData.category,
      price: parseFloat(formData.price),
      cost: parseFloat(formData.cost),
      stock: parseInt(formData.stock),
      minStock: parseInt(formData.minStock),
      barcode: formData.barcode
    };

    if (editingProduct) {
      saveProducts(products.map(p => p.id === editingProduct.id ? product : p));
    } else {
      saveProducts([...products, product]);
    }

    resetForm();
  };

  const handleEdit = (product: Product) => {
    setEditingProduct(product);
    setFormData({
      name: product.name,
      category: product.category,
      price: product.price.toString(),
      cost: product.cost.toString(),
      stock: product.stock.toString(),
      minStock: product.minStock.toString(),
      barcode: product.barcode || ""
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (id: string) => {
    if (confirm("¿Estás seguro de eliminar este producto?")) {
      saveProducts(products.filter(p => p.id !== id));
    }
  };

  const resetForm = () => {
    setFormData({
      name: "",
      category: "Vinos",
      price: "",
      cost: "",
      stock: "",
      minStock: "10",
      barcode: ""
    });
    setEditingProduct(null);
    setIsDialogOpen(false);
  };

  const filteredProducts = products.filter(p => {
    const matchesSearch = p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         p.barcode?.includes(searchTerm);
    const matchesCategory = categoryFilter === "all" || p.category === categoryFilter;
    return matchesSearch && matchesCategory;
  });

  const lowStockProducts = products.filter(p => p.stock <= p.minStock);

  return (
    <div className={`p-3 md:p-6 space-y-4 md:space-y-6 min-h-full ${isDark ? 'bg-[#1f2937]' : 'bg-[#F8FAFC]'}`}>
      <div className="flex justify-between items-start md:items-center gap-2">
        <div className="flex-1 min-w-0">
          <h1 className={`text-2xl md:text-3xl font-bold ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>Inventario</h1>
          <p className={`text-sm md:text-base ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Gestiona tus productos</p>
        </div>
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button onClick={resetForm} size="sm" className="flex-shrink-0 bg-[#C89B6D] hover:bg-[#B8895D] text-white shadow-lg">
              <Plus className="h-4 w-4 md:mr-2" />
              <span className="hidden md:inline">Agregar</span>
            </Button>
          </DialogTrigger>
          <DialogContent className={`max-w-md ${isDark ? 'bg-[#2c3545] border-[#3a4556] text-[#f1f5f9]' : 'bg-white border-gray-200 text-[#0F172A]'}`}>
            <DialogHeader>
              <DialogTitle className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>{editingProduct ? "Editar Producto" : "Nuevo Producto"}</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <Label htmlFor="name" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Nombre</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={e => setFormData({ ...formData, name: e.target.value })}
                  required
                  className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                />
              </div>
              <div>
                <Label htmlFor="category" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Categoría</Label>
                <Select value={formData.category} onValueChange={value => setFormData({ ...formData, category: value })}>
                  <SelectTrigger className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9]' : 'bg-white border-gray-300 text-[#0F172A]'}>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
                    {CATEGORIES.map(cat => (
                      <SelectItem key={cat} value={cat} className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>{cat}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="cost" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Costo</Label>
                  <Input
                    id="cost"
                    type="number"
                    value={formData.cost}
                    onChange={e => setFormData({ ...formData, cost: e.target.value })}
                    required
                    className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                  />
                </div>
                <div>
                  <Label htmlFor="price" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Precio Venta</Label>
                  <Input
                    id="price"
                    type="number"
                    value={formData.price}
                    onChange={e => setFormData({ ...formData, price: e.target.value })}
                    required
                    className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="stock" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Stock</Label>
                  <Input
                    id="stock"
                    type="number"
                    value={formData.stock}
                    onChange={e => setFormData({ ...formData, stock: e.target.value })}
                    required
                    className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                  />
                </div>
                <div>
                  <Label htmlFor="minStock" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Stock Mínimo</Label>
                  <Input
                    id="minStock"
                    type="number"
                    value={formData.minStock}
                    onChange={e => setFormData({ ...formData, minStock: e.target.value })}
                    required
                    className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="barcode" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Código de Barras (opcional)</Label>
                <Input
                  id="barcode"
                  value={formData.barcode}
                  onChange={e => setFormData({ ...formData, barcode: e.target.value })}
                  className={isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}
                />
              </div>
              <div className="flex gap-2">
                <Button type="submit" className="flex-1 bg-[#C89B6D] hover:bg-[#B8895D] text-white shadow-lg">
                  {editingProduct ? "Actualizar" : "Crear"}
                </Button>
                <Button type="button" variant="outline" onClick={resetForm} className={isDark ? 'bg-transparent border-[#3a4556] text-[#f1f5f9] hover:bg-[#1f2937]' : 'bg-white border-gray-300 text-[#0F172A] hover:bg-gray-50'}>
                  Cancelar
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      {lowStockProducts.length > 0 && (
        <Card className={isDark ? 'border-[#C89B6D] bg-[#3a2f22]' : 'border-orange-300 bg-orange-50'}>
          <CardHeader className="p-3 md:p-6">
            <CardTitle className={`flex items-center text-sm md:text-base ${isDark ? 'text-[#C89B6D]' : 'text-orange-700'}`}>
              <AlertCircle className="mr-2 h-4 w-4 md:h-5 md:w-5 flex-shrink-0" />
              Stock Bajo
            </CardTitle>
          </CardHeader>
          <CardContent className="p-3 md:p-6 pt-0">
            <div className="flex flex-wrap gap-1.5 md:gap-2">
              {lowStockProducts.map(p => (
                <Badge key={p.id} variant="outline" className={`text-xs ${isDark ? 'border-[#C89B6D] text-[#C89B6D]' : 'border-orange-400 text-orange-700'}`}>
                  {p.name} ({p.stock})
                </Badge>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      <Card className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
        <CardHeader className="p-3 md:p-6">
          <div className="flex flex-col md:flex-row gap-2 md:gap-4">
            <div className="flex-1">
              <Input
                placeholder="Buscar..."
                value={searchTerm}
                onChange={e => setSearchTerm(e.target.value)}
                className={`text-sm ${isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9] focus:border-[#C89B6D]' : 'bg-white border-gray-300 text-[#0F172A] focus:border-[#C89B6D]'}`}
              />
            </div>
            <Select value={categoryFilter} onValueChange={setCategoryFilter}>
              <SelectTrigger className={`w-full md:w-48 ${isDark ? 'bg-[#1f2937] border-[#3a4556] text-[#f1f5f9]' : 'bg-white border-gray-300 text-[#0F172A]'}`}>
                <SelectValue />
              </SelectTrigger>
              <SelectContent className={isDark ? 'bg-[#2c3545] border-[#3a4556]' : 'bg-white border-gray-200'}>
                <SelectItem value="all" className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>Todas</SelectItem>
                {CATEGORIES.map(cat => (
                  <SelectItem key={cat} value={cat} className={isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}>{cat}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent className="p-0 md:p-6">
          <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow className={isDark ? 'border-[#3a4556]' : 'border-gray-200'}>
                <TableHead className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Producto</TableHead>
                <TableHead className={`hidden md:table-cell text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Categoría</TableHead>
                <TableHead className={`hidden sm:table-cell text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Precio</TableHead>
                <TableHead className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Stock</TableHead>
                <TableHead className={`text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Estado</TableHead>
                <TableHead className={`text-right text-xs md:text-sm ${isDark ? 'text-[#94a3b8]' : 'text-gray-600'}`}>Acciones</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredProducts.map(product => (
                <TableRow key={product.id} className={isDark ? 'border-[#3a4556]' : 'border-gray-200'}>
                  <TableCell className={`font-medium text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
                    <div>
                      <div>{product.name}</div>
                      <div className={`text-xs ${isDark ? 'text-[#94a3b8]' : 'text-gray-500'} md:hidden`}>{product.category}</div>
                    </div>
                  </TableCell>
                  <TableCell className={`hidden md:table-cell text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>{product.category}</TableCell>
                  <TableCell className={`hidden sm:table-cell text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>${product.price.toLocaleString()}</TableCell>
                  <TableCell className={`text-xs md:text-sm ${isDark ? 'text-[#f1f5f9]' : 'text-[#0F172A]'}`}>
                    <div className="flex items-center gap-1 md:gap-2">
                      <Package className="h-3 w-3 md:h-4 md:w-4 text-[#C89B6D]" />
                      {product.stock}
                    </div>
                  </TableCell>
                  <TableCell>
                    {product.stock <= product.minStock ? (
                      <Badge variant="destructive" className="text-xs">Bajo</Badge>
                    ) : product.stock <= product.minStock * 2 ? (
                      <Badge variant="outline" className="border-[#C89B6D] text-[#C89B6D] text-xs">Medio</Badge>
                    ) : (
                      <Badge variant="outline" className="border-[#4ade80] text-[#4ade80] text-xs hidden md:inline-flex">Normal</Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-1 md:gap-2">
                      <Button variant="ghost" size="sm" onClick={() => handleEdit(product)} className={`text-[#C89B6D] ${isDark ? 'hover:bg-[#3a4556]' : 'hover:bg-gray-100'}`}>
                        <Edit className="h-3 w-3 md:h-4 md:w-4" />
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => handleDelete(product.id)} className={`text-red-500 ${isDark ? 'hover:bg-[#3a4556]' : 'hover:bg-gray-100'}`}>
                        <Trash2 className="h-3 w-3 md:h-4 md:w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
