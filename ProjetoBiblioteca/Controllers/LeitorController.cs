using Microsoft.AspNetCore.Mvc;
using MySql.Data.MySqlClient;
using ProjetoBiblioteca.Data;
using ProjetoBiblioteca.Models;


namespace ProjetoBiblioteca.Controllers
{
    public class LeitorController : Controller
    {
        public readonly Database db = new Database();
        public IActionResult Index()
        {
            var lista = new List<Leitor>();
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_leitor_listar", conn) { CommandType = System.Data.CommandType.StoredProcedure };
            using var rd = cmd.ExecuteReader();
            while (rd.Read())
            {
                lista.Add(new Leitor
                {
                    id_leitor = rd.GetInt32("id_leitor"),
                    nomeleitor = rd.GetString("nomeleitor")
                });

            }
            return View(lista);
        }
        public IActionResult Criar()
        {
            return View();
        }
        [HttpPost, ValidateAntiForgeryToken]
         public IActionResult Criar(Leitor model, IFormFile? foto)
            
        {
            string? relPath = null;
            if (foto != null && foto.Length > 0)
            {
                var ext = Path.GetExtension(foto.FileName);
                var fileName = $"{Guid.NewGuid()}{ext}";
                var saveDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "foto");
                Directory.CreateDirectory(saveDir);
                var absPath = Path.Combine(saveDir, fileName);
                using var fs = new FileStream(absPath, FileMode.Create);
                foto.CopyTo(fs);
                relPath = Path.Combine("foto", fileName).Replace("\\", "/");
            }

            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_leitor_criar", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("p_nome_leitor", model.nomeleitor);
            cmd.Parameters.AddWithValue("p_foto_leitor", (object?) relPath ?? DBNull.Value);

            cmd.ExecuteNonQuery();

            TempData["ok"] = "Leitor Cadastrado!";

            return RedirectToAction(nameof(Index));
        }
    }
}
