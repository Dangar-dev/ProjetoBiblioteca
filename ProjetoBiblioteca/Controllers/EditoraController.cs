using System.Security.Cryptography;
using Microsoft.AspNetCore.Mvc;
using MySql.Data.MySqlClient;
using ProjetoBiblioteca.Data;
using ProjetoBiblioteca.Models;

namespace ProjetoBiblioteca.Controllers
{
    public class EditoraController : Controller
    {
        public readonly Database db = new Database();
        public IActionResult Index()
        {
            var lista = new List<Editora>();
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_editora_listar", conn) { CommandType = System.Data.CommandType.StoredProcedure };
            using var rd = cmd.ExecuteReader();
            while (rd.Read())
            {
                lista.Add(new Editora
                {
                    Id = rd.GetInt32("id"),
                    Nome = rd.GetString("nome")
                });
            }
            return View(lista);
        }
        public IActionResult CriarEditora()
        {
            return View();
        }
        [HttpPost]
        public IActionResult CriarEditora(Editora editora)
        {
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_editora_criar", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("p_nome", editora.Nome);
            cmd.ExecuteNonQuery();
            return RedirectToAction("CriarEditora");
        }

        [HttpGet]
        public IActionResult Editar(int id
        {
            using var conn = db.GetConnection();
            Autor? autor = null;
            using (var cmd = new MySqlCommand("sp_autor_obter", conn) { CommandType = System.Data.CommandType.StoredProcedure })
            {
                cmd.Parameters.AddWithValue("p_id", id);
                using var rd = cmd.ExecuteReader();
                if (rd.Read())
                {

                    autor = new Autor
                    {
                        Id = rd.GetInt32("id"),
                        Nome = rd.GetString("Nome")
                    };

                }


            }
            return View(autor);
        }
        [HttpPost, AutoValidateAntiforgeryToken]
        public IActionResult Editar(Autor model)
        {
            if (model.Id <= 0) return NotFound();
            if (string.IsNullOrWhiteSpace(model.Nome))
            {

                ModelState.AddModelError("", "informe nome ");

            }
            using var conn2 = db.GetConnection();
            using var cmd = new MySqlCommand("sp_autor_atualizar", conn2) { CommandType = System.Data.CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("id", model.Id);
            cmd.Parameters.AddWithValue("p_nome", model.Nome);
            cmd.ExecuteNonQuery();

            TempData["ok"] = "Autor Atualizado";
            return RedirectToAction(nameof(Index);

        }

        [HttpPost, ValidateAntiForgeryToken]
    }
}
