using api_app_notes.Model.DTO;
using api_app_notes.Model.Entity;
using api_app_notes.Model.Service;
using api_app_notes.Model.Service.Imp;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Text;

namespace api_app_notes.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserClientController : ControllerBase
    {

        private readonly IUserClientService _userService;

        public UserClientController(IUserClientService userService)
        {
            _userService = userService;
        }

        // GET: api/user
        [HttpGet]
        public async Task<IEnumerable<UserClientDTO>> GetAllUsers()
        {
            var a = await _userService.GetAllUsers();
            if (a == null || !a.Any())
            {
                return (IEnumerable<UserClientDTO>)NotFound();
            }
            return a.Select(a => new UserClientDTO{
                Email = a.Email,
                Name = Encoding.UTF8.GetString(a.Name),
                Phone = Encoding.UTF8.GetString(a.Phone),
                Pin = Encoding.UTF8.GetString(a.Pin)
            }).ToList();
        }

        // GET: api/user/{email}
        [HttpGet("{email}")]
        public async Task<ActionResult<UserClientDTO>> GetUserByEmail(string email)
        {
            var a = await _userService.GetUserByEmail(email);
            if (a == null)
            {
                return BadRequest("tài khoản không tồn tại !");
            }
            return new UserClientDTO
            {
                Email = a.Email,
                Name = Encoding.UTF8.GetString(a.Name),
                Phone = Encoding.UTF8.GetString(a.Phone),
                Pin = Encoding.UTF8.GetString(a.Pin)
            };
        }

        // POST: api/user
        [HttpPost("AddUser")]
        public async Task<IActionResult> AddUser(UserClientDTO user)
        {
            bool a = await _userService.AddUser(new UserClient
            {
                Email = user.Email,
                Name = Encoding.UTF8.GetBytes(user.Name),
                Phone = Encoding.UTF8.GetBytes(user.Phone),
                Pin = Encoding.UTF8.GetBytes("")
            });
            return Ok(a);
        }
        [HttpPut("UpdatePin/{email}")]
        public async Task<IActionResult> UpdateUserPin(string email , UserClientDTO user)
        {
            if(email != user.Email)
            {
                return Ok(false);
            }
            bool a = await _userService.UpdateUserPin(new UserClient
            {
                Email = user.Email,
                Pin = Encoding.UTF8.GetBytes(user.Pin)
            });
            return Ok(a);
        }
        /*// PUT: api/user/{email}
        [HttpPut("{email}")]
        public IActionResult UpdateUser(string email, UserClient user)
        {
            if (email != user.Email)
            {
                return BadRequest();
            }
            _userService.UpdateUser(user);
            return NoContent();
        }

        // DELETE: api/user/{email}
        [HttpDelete("{email}")]
        public IActionResult DeleteUser(string email)
        {
            _userService.DeleteUser(email);
            return NoContent();
        }*/
    }
    
}
