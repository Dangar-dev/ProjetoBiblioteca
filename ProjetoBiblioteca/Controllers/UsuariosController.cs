using Microsoft.AspNetCore.Mvc;
using ProjetoBiblioteca.Models;
using MySql.Data.MySqlClient;
using ProjetoBiblioteca.Data;
using BCrypt.Net;
using ProjetoBiblioteca.Autenticacao;

namespace ProjetoBiblioteca.Controllers
{
    [SessionAuthorize(RoleAnyOf = "Admin")]

    public class UsuariosController : Controller
    {
        public readonly Database db = new Database(); 
        public IActionResult Index()
        {
            return View();
        }
        public IActionResult CriarUsuario()
        {
            return View();
        }
        
        [HttpPost]
        public IActionResult CriarUsuario(Usuarios vm)
        {
            using var conn = db.GetConnection();
            using var cmd = new MySqlCommand("sp_usuario_criar",conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            var senhaHash = BCrypt.Net.BCrypt.HashPassword(vm.senha_hash, workFactor: 12);

            cmd.Parameters.AddWithValue("p_nome",vm.nome);
            cmd.Parameters.AddWithValue("p_email", vm.email);
            cmd.Parameters.AddWithValue("p_senha_hash", senhaHash);
            cmd.Parameters.AddWithValue("p_role", vm.role);
            cmd.ExecuteNonQuery();
            return RedirectToAction("CriarUsuario");
        }

    }
    
}
