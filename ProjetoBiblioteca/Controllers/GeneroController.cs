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

        [HttpGet]
        public IActionResult Editar(int id)
        {

            using var conn = db.GetConnection();

            Genero? genero = null;
            using (var cmd = new MySqlCommand("sp_genero_obter", conn) { CommandType = System.Data.CommandType.StoredProcedure })
            {
                cmd.Parameters.AddWithValue("p_id", id);
                using var rd = cmd.ExecuteReader();
                if (rd.Read())
                {
                    genero = new Genero
                    {
                        Id = rd.GetInt32("id"),
                        Nome = rd.GetString("Nome")
                    };
                }
            }
            return View(genero);




        }
        [HttpPost, ValidateAntiForgeryToken]
        public IActionResult Editar(Genero model)
        {
            if (model.Id <= 0) return NotFound();
            if (string.IsNullOrWhiteSpace(model.Nome))
            {

                ModelState.AddModelError("", "Informe nome ");

            }
            using var conn2 = db.GetConnection();
            using var cmd = new MySqlCommand("sp_genero_atualizar", conn2) { CommandType = System.Data.CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("p_id", model.Id);
            cmd.Parameters.AddWithValue("p_nome", model.Nome);
            cmd.ExecuteNonQuery();

            TempData["ok"] = "Genero Atualizado!";
            return RedirectToAction(nameof(Index));
        }


        [HttpPost, ValidateAntiForgeryToken]

        public IActionResult Excluir(int id)
        {
            using var conn = db.GetConnection();
            try
            {
                using var cmd = new MySqlCommand("sp_genero_excluir", conn) { CommandType = System.Data.CommandType.StoredProcedure };
                cmd.Parameters.AddWithValue("p_id", id);
                cmd.ExecuteNonQuery();
                TempData["ok"] = "Genero excluido!";

            }
            catch (MySqlException ex)
            {
                TempData["ok"] = ex.Message;
            }
            return RedirectToAction(nameof(Index));
        }
    }
}
