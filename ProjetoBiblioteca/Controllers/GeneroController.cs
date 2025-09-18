using Microsoft.AspNetCore.Mvc;
using MySql.Data.MySqlClient;
using ProjetoBiblioteca.Data;
using ProjetoBiblioteca.Models;
using ProjetoBiblioteca.Autenticacao;

namespace ProjetoBiblioteca.Controllers
         
{
    [SessionAuthorize]

    public class GeneroController : Controller
    {
        public readonly Database db = new Database();
        public IActionResult Index()
        {
            var lista = new List<Genero>();
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_genero_listar", conn) { CommandType = System.Data.CommandType.StoredProcedure };
            using var rd = cmd.ExecuteReader();
            while (rd.Read())
            {
                lista.Add(new Genero
                {
                    Id = rd.GetInt32("id"),
                    Nome = rd.GetString("nome")
                });
            }
            return View(lista);
        }
        public IActionResult CriarGenero()
        {
            return View();
        }
        [HttpPost]
        public IActionResult CriarGenero(Genero genero)
        {
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_genero_criar", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("p_nome", genero.Nome);
            cmd.ExecuteNonQuery();
            return RedirectToAction("CriarGenero");
        }
    }
}
