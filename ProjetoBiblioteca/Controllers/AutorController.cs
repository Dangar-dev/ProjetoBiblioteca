using Microsoft.AspNetCore.Mvc;
using MySql.Data.MySqlClient;
using ProjetoBiblioteca.Data;
using ProjetoBiblioteca.Models;

namespace ProjetoBiblioteca.Controllers
{
    public class AutorController : Controller
    {
        public readonly Database db = new Database();
        public IActionResult Index()
        {
            var lista = new List<Autor>();
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_autor_listar", conn) { CommandType = System.Data.CommandType.StoredProcedure };
            using var rd = cmd.ExecuteReader();
            while (rd.Read())
            {
                lista.Add(new Autor
                {
                    Id = rd.GetInt32("id"),
                    Nome = rd.GetString("nome")
                });
            }
            return View(lista);
        }                           
        public IActionResult CriarAutor()
        {
            return View();
        }
        [HttpPost]
        public IActionResult CriarAutor(Autor autor)
        {
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_autor_criar", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("p_nome", autor.Nome);
            cmd.ExecuteNonQuery();
            return RedirectToAction("CriarAutor");
        }
    }
}
