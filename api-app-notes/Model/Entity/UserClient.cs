using System.ComponentModel.DataAnnotations;

namespace api_app_notes.Model.Entity
{
    public class UserClient
    {
        [Key]
        public string Email { get; set; }
        public byte[] Name { get; set; }
        public byte[] Phone { get; set; }
        public byte[] Pin { get; set; }
        public ICollection<Notes> Notes { get; set; }
    }
}
