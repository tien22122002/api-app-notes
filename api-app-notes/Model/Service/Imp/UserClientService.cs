using api_app_notes.Data;
using api_app_notes.Model.Entity;
using Microsoft.EntityFrameworkCore;

namespace api_app_notes.Model.Service.Imp
{
    public class UserClientService : IUserClientService
    {
        private readonly DataContext _context;

        public UserClientService(DataContext context)
        {
            _context = context;
        }
        private async Task<bool> SaveChangesAsync()
        {
            try
            {
                int recordsAffected = await _context.SaveChangesAsync();
                return recordsAffected > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi lưu dữ liệu: " + ex.Message);
                return false;
            }
        }

        // Lấy tất cả người dùng
        public async Task<IEnumerable<UserClient>> GetAllUsers()
        {
            return await _context.UserClient.ToListAsync();
        }

        // Lấy một người dùng theo email
        public async Task<UserClient> GetUserByEmail(string email)
        {
            return await _context.UserClient.FirstOrDefaultAsync(u => u.Email == email);
        }

        // Thêm một người dùng mới
        public async Task<bool> AddUser(UserClient user)
        {
            if(await _context.UserClient.AnyAsync(u => u.Email == user.Email))
            {
                return false;
            }
            _context.UserClient.Add(user);
            return await SaveChangesAsync();
        }

        // Cập nhật thông tin của một người dùng
        public async Task<bool> UpdateUser(UserClient user)
        {
            if (!await _context.UserClient.AnyAsync(u => u.Email == user.Email))
            {
                return false;
            }
            _context.UserClient.Update(user);
            return await SaveChangesAsync();
        }
        public async Task<bool> UpdateUserPin(UserClient user)
        {
            var UserEntity = await _context.UserClient.FirstOrDefaultAsync(u => u.Email == user.Email);
            UserEntity.Pin = user.Pin;
            _context.UserClient.Update(UserEntity);
            return await SaveChangesAsync();
        }

        // Xóa một người dùng
        public async Task<bool> DeleteUser(string email)
        {
            var userToDelete = await _context.UserClient.FirstOrDefaultAsync(u => u.Email == email);
            if (userToDelete == null)
            {
                return false;
            }
            _context.UserClient.Remove(userToDelete);
            return await SaveChangesAsync();
        }
    }
}
