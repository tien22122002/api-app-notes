using api_app_notes.Model.Entity;

namespace api_app_notes.Model.Service
{
    public interface IUserClientService
    {
        Task<IEnumerable<UserClient>> GetAllUsers();
        Task<UserClient> GetUserByEmail(string email);
        Task<bool> AddUser(UserClient user);
        Task<bool> UpdateUser(UserClient user);
        Task<bool> UpdateUserPin(UserClient user);
        Task<bool> DeleteUser(string email);
    }
}
