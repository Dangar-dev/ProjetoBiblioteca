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

        [HttpGet]
        public IActionResult Editar(int id)
        {

            using var conn = db.GetConnection();

            Autor? autor = null;
            using (var cmd = new MySqlCommand("sp_autor_obter", conn) { CommandType = System.Data.CommandType.StoredProcedure })
            {
                cmd.Parameters.AddWithValue("p_id", id);
                using var rd = cmd.ExecuteReader();
                if(rd.Read())
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
        [HttpPost, ValidateAntiForgeryToken]
         public IActionResult Editar(Autor model)
        {
            if (model.Id <= 0) return NotFound();
            if(string.IsNullOrWhiteSpace(model.Nome))
                {
            
                ModelState.AddModelError("", "Informe nome ");

            }
            using var conn2 = db.GetConnection();
            using var cmd = new MySqlCommand("sp_autor_atualizar", conn2) { CommandType = System.Data.CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("p_id", model.Id);
            cmd.Parameters.AddWithValue("p_nome", model.Nome);
            cmd.ExecuteNonQuery();

            TempData["ok"] = "Autor Atualizado!";
            return RedirectToAction(nameof(Index));
        }


        [HttpPost, ValidateAntiForgeryToken]

        public IActionResult Excluir(int id)
        {
            using var conn = db.GetConnection();
            try
            {
                using var cmd = new MySqlCommand("sp_autor_excluir", conn) { CommandType = System.Data.CommandType.StoredProcedure };
                cmd.Parameters.AddWithValue("p_id", id);
                cmd.ExecuteNonQuery();
                TempData["ok"] = "Autor excluido!";

            }
            catch (MySqlException ex)
            {
                TempData["ok"] = ex.Message;
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
